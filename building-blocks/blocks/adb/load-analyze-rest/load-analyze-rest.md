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
News API provides a simple API to retrive news from various sources. Get started by creating a News API account:

1. Register for an API key from the [News API](https://newsapi.org/register). 
2. Complete the fields on the registration page, including your name, email and password. Agree to the terms and click **Submit**.
3. You will receive an email from News API that includes your API key. You will need the API key to make REST calls against the service.

## Task 2: Create a PLSQL function that retrieves news for an actor
Now that you have the API key, create a PLSQL function that uses the key to retreive news for an actor.
1. Go to SQL Worksheet
2. We will use the `Everything` [News API endpoint](https://newsapi.org/docs/endpoints/everything). 
3. Copy and paste the function below into the SQL worksheet and click **Run Script**

    ```
    <copy>
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
            apikey          varchar2(100) := 'd4c7c627a9f241e1b7a5e96c38f4d455';
            endpoint        varchar2(100) := 'https://newsapi.org/v2/everything';
        
        
        begin        
            -- Fill in the parameters that are unique to this endpoint
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
        
            -- Get the response
            result_row := dbms_cloud.get_response_text(resp);
        
            -- Return the result
            return result_row;
        
        end;
    / 
    </copy>
    ```