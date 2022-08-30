<!---
{
    "name":"Load and Analyze Data from REST Services",
    "description":"Analyze data sourced from REST services. Using the News API as an example.<ul><li>Create an Account on newsapi.org</li><li>Create a PLSQL function that retrieves news for actors</li><li>Perform a sentiment analysis on the article descriptions</li><li>Find which actors are generating buzz - both good and bad</li></ul>"
}
--->
# Load and Analyze the News from REST Endpoints

## Introduction

There are so many interesting and potentially useful data sets available today via REST: social, financial, science, health, weather - the list goes on and on. Autonomous Database makes it really easy to integrate these sources using SQL queries – eliminating the need for intermediate processing and storage and making that data available to any SQL client.

In this lab, you will find the latest news about actors and then perform a sentiment analysis of that news. This information can help decide which movies to promote on the MovieStream site - allowing MovieStream to take advantage of "buzz" to drive revenue.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:
* Create an account on News API (https://newsapi.org/) and retrieve an API key
* Create a PLSQL function that retrieves the latest news for actors
* Perform a sentiment analysis on the article descriptions
* Which actors are generating buzz - both good and bad?


### Prerequisites

- This lab requires:
    * a provisioned ADB instance
    * movies loaded from object storage

## Task 1: Create an account on News API and retrieve an API key
The News API provides a simple REST API to retrive news from various sources. Get started by creating a News API account:

1. Register for an API key from the [News API](https://newsapi.org/register).
2. Complete the fields on the registration page, including your name, email and password. Agree to the terms and click **Submit**.
3. You will receive an email from News API that includes your API key. You will need the API key to make REST calls against the service.
4. We will use the [`Everything` News API endpoint (`https://newsapi.org/v2/everything`) ](https://newsapi.org/docs/endpoints/everything) The key parameters for the REST endpoint are:

    | Parameter | Description |
    | --------- | ----------- |
    | q         | The search term. This will be an actor |
    | searchin  | We will search news items' titles and descriptions (the full article requires more work) |
    | from      | The oldest article. We will default to one week ago |
    | to      | The newest article. We will default to today |
    | sortby    | We will sort by the published date |
    {: title="News API parameters"}

## Task 2: Create a PLSQL function that retrieves news for an actor
Now that you have the API key, create a PLSQL function that queries the REST endpoint using the parameters above.
1. Go to SQL Worksheet.
2. Ensure that the public REST endpoint is accessible by our PL/SQL function. Copy and paste the following API call into SQL Worksheet to update the access control list. Click **Run Script**. This will allow the ADMIN user to call out to any public host.
    ```
    <copy>
    begin

    dbms_network_acl_admin.append_host_ace(
         host => '*',
         ace => xs$ace_type(privilege_list => xs$name_list('http'),
                             principal_name => 'ADMIN',
                             principal_type => xs_acl.ptype_db)
        );
    end;
    /
    </copy>
    ```
3. Create the function that queries the News API REST endpoint. Copy and paste the function below into the SQL worksheet. Replace **`<your api key>`** with the API key that the News API sent to you. After replacing the API key, click **Run Script**.

    ```
    <copy>
    set define off;  -- turns off prompting for parameter values

    create or replace function get_news (
                                news_search in varchar2 default '+"Tom Hanks"',
                                from_date in varchar2 default to_char(sysdate-7, 'YYYY-MM-DD'),
                                end_date in varchar2 default to_char(sysdate, 'YYYY-MM-DD')
                                )    
        return clob is

            result_row      clob;

            -- REST management
            req             varchar2(1000);
            resp            dbms_cloud_types.resp;            
            params          varchar2(1000);
            apikey          varchar2(100) := '<your api key>';
            endpoint        varchar2(100) := 'https://newsapi.org/v2/everything';


        begin        
            -- Create the URL based on the parameters, API Key and rest endpoint
            params      :=  '?q=' || news_search
                            || '&apikey=' ||apikey
                            || '&from=' || from_date
                            || '&to=' || end_date
                            || '&sortBy=publishedAt&language=en&searchIn=title,description';


            req := utl_url.escape(endpoint || params);

            -- send the request and process the result
            resp := dbms_cloud.send_request(
                credential_name => null,
                -- headers         => reqheader,        
                uri             => req,
                method          => DBMS_CLOUD.METHOD_GET,
                cache           => true
            );

            -- Get the response. This is in JSON format
            result_row := dbms_cloud.get_response_text(resp);

            -- Return the result
            return result_row;

        end;
    /
    </copy>
    ```
    **`DBMS_CLOUD.SEND_REQUEST`** is the key function; it queries the endpoint and returns a response object. This response object is then passed to **`BMS_CLOUD.GET_RESPONSE_TEXT`** to retrieve the news articles in JSON format.

4. Query the News API for the top 20 actors. The result of the query is saved into a table.

    ```
    <copy>
    create table news as
    with top_actors as (
        select  
            jt.actor,
            sum(gross)
        from movie m,
            json_table(m.cast,'$[*]' columns (actor path '$')) jt    
        where actor != 'novalue'
        group by jt.actor
        order by 2 desc nulls last
        fetch first 20 rows only
    )
    select
        actor,
        get_news(actor) as json_document
    from top_actors
    ;
    </copy>
    ```

    This query is broken into two parts:
    - A subquery - select the top 20 actors based on box office revenue.
    - For each of those top actors, get the latest news by calling the `get_news` function.

    5. Let's see the news for Johnny Depp. Note, because this is querying a live news feed, your results will definitely be different!!
        ```
        <copy>
        select
            actor,
            json_query(json_document, '$' returning clob pretty) as news_articles
        from news
        where actor = 'Johnny Depp';
        </copy>
        ```
    Lots of news - 251 articles across publications. Unfortunately, the news is not all good.

        ![News results](images/adb-query-news.png)

    6. Finally, let's clean up the JSON and make it more structured and easier to analyze. Use the **`JSON_TABLE`** function to turn the nested arrays into rows. Again, we'll create a table with a row for each article:

        ```
        <copy>
        create table news_buzz as
        select
            actor,
            json_value(json_document, '$.totalResults' returning number) as buzz,
            author,
            source,
            title,
            description
        from news n,
            json_table(n.json_document, '$.articles[*]'
                columns (
                    source      varchar2(100)    path '$.source.name',
                    author      varchar2(100)    path '$.author',
                    title       varchar2(200)    path '$.title',
                    description varchar2(1000)   path '$.description'

                )
            ) jt;
        </copy>
        ```

    7. Let's review the results:
        ```
        <copy>
        select *
        from news_buzz;
        </copy>
        ```

        It's now easy to see each article that refers to an actor, including its title and description.

        ![Query news buzz](images/adb-query-news-buzz.png)

## Task 3: Analyze the sentiment of each article description        
Now that we have the latest news for each actor, let's derive the sentiment of those articles. Oracle Database has powerful text functions for tokenizing the text and then analyzing it. In our case, we'll use the defaults; however, you can perform much more sophisticated models using training methods.

1. Specify the type of lexer to use. We will use the "automatic" version, which will be fine for our use case. Copy and paste the following into the SQL Worksheet and click **Run Statement**:

    ```
    <copy>
    exec ctx_ddl.create_preference('newsautolexer','AUTO_LEXER');
    </copy>
    ```

2. Create the sentiment index:
    ```
    <copy>
    create index news_sentiment_idx
    on news_buzz(description)
    indextype is ctxsys.context
    parameters ('lexer newsautolexer stoplist ctxsys.default_stoplist');
    </copy>
    ```
    The index creation analyzes each article, deriving the sentiment and storing it in the index.

3. Let's look at the sentiment of some of Johnny Depp's news:
    ```
    <copy>
    select
        actor,
        ctx_doc.sentiment_aggregate('news_sentiment_idx', rowid) as sentiment,
        description     
    from news_buzz
    where actor = 'Johnny Depp'
    order by sentiment
    ;
    </copy>
    ```
    As to be expected, the computed sentiment isn't great. However, it's not all bad; as you scroll through the results, there are some positive articles. Also, the description field is fairly small. A richer text field would likely produce even better results.

    ![](images/adb-sentiment-analysis.png)

4. MovieStream will want to consider which movies to promote on the site. Actors that are generating buzz and the type of news will likely have some influence on their recommendations. Below are the rankings for our actors:
    ```
    <copy>
    select
        actor,
        round(avg(ctx_doc.sentiment_aggregate('news_sentiment_idx', rowid)), 1) as avg_sentiment,
        max(buzz)
    from news_buzz
    group by actor
    order by 3 desc;
    </copy>
    ```

    ![Ranking by buzz](images/adb-ranking-by-buzz.png)

This completes this lab. You now know how to integrate and analyze data coming from REST endpoints in Autonomous Database.

## Acknowledgements

* **Author** - Marty Gubar, Autonomous Database Product Management
* **Last Updated By/Date** - Marty Gubar, July 2022
