# Lab 3: Secure the Endpoint with OAuth2

## Introduction

In the previous lab, the endpoint was publicly accessible and did not require authentication which is insecure. In this lab, you will secure it using the OAuth 2.0 client credentials , the standard pattern for server-to-server communication. After completing the lab, only clients with a valid access token will be able to scrape your metrics.

*Estimated Lab Time:* 10 minutes

### Objectives

- Create an ORDS role and privilege
- Create an OAuth2 client with client credentials grant type
- Test the complete OAuth2 token flow
- Verify unauthenticated access is rejected

### Prerequisites

- Completion of [Lab 2](?lab=create-ords-endpoint)

## Task 1: Create a Role

Connected as **PROM\_EXPORTER** in your SQL interpreter (SQLcl or SQL Worksheet), run:

 ```sql
 BEGIN
     ORDS.CREATE_ROLE(p_role_name => 'prom_scraper');
     COMMIT;
 END;
 /
 ```

## Task 2: Define a Privilege and Map to the Module

Run the following block to create a privilege and associate it with the `prometheus` module:

 ```sql
 DECLARE
        l_roles    OWA.VC_ARR;
        l_modules  OWA.VC_ARR;
    BEGIN
        l_roles(1)   := 'prom_scraper';
        l_modules(1) := 'prometheus';

        ORDS.DEFINE_PRIVILEGE(
            p_privilege_name => 'prom_priv',
            p_roles          => l_roles,
            p_modules        => l_modules,
            p_patterns       => OWA.VC_ARR(),
            p_label          => 'Prometheus Scraper',
            p_description    => 'Access to /prom/v1/metrics'
        );
        COMMIT;
    END;
 /
 ```

**Note:** The `ORDS.DEFINE_PRIVILEGE` procedure (with `OWA.VC_ARR` arrays) is the correct API for ORDS 25.x. The older `ORDS.CREATE_PRIVILEGE` procedure has a different signature and may produce errors on Autonomous AI Database.

## Task 3: Create the OAuth2 Client

Run the following to create a client credentials OAuth2 client:

 ```sql
   BEGIN
        OAUTH.CREATE_CLIENT(
            p_name            => 'prometheus',
            p_grant_type      => 'client_credentials',
            p_owner           => 'Prometheus Server',
            p_description     => 'Prometheus scraper client',
            p_support_email   => 'your-email@example.com',
            p_privilege_names => 'prom_priv'
        );
        COMMIT;
    END;
 /
 ```

## Task 4: Grant the Role to the Client

Associate the client with the scraper role:

 ```sql
  BEGIN
        OAUTH.GRANT_CLIENT_ROLE(
            p_client_name => 'prometheus',
            p_role_name   => 'prom_scraper'
        );
        COMMIT;
    END;
 /
 ```

## Task 5: Retrieve the Client Credentials

1. Query the credentials:

    ```sql
    SELECT name, client_id, client_secret FROM user_ords_clients WHERE name = 'prometheus';
    ```

2. Copy the `client_id` and `client_secret` values. You will need them to configure Prometheus in [Lab 4](?lab=deploy-prometheus-grafana).

 <!-- Screenshot placeholder: Screenshot of client_id and client_secret query result (with values partially redacted) -->

## Task 6: Test the OAuth2 Flow

1. From a compute instance inside the VCN (or wait until [Lab 4](?lab=deploy-prometheus-grafana)), test the token endpoint:

    ```bash
    # Step 1: Get an access token
    curl -k --user <client_id>:<client_secret> \
      --data "grant_type=client_credentials" \
      https://<scan-hostname>/ords/<DB_NAME>/prom_exporter/oauth/token
    ```

    You should receive:
    ```json
    {"access_token":"<token>","token_type":"bearer","expires_in":3600}
    ```

2. Use the token to access the endpoint:

    ```bash
    # Step 2: Call the metrics endpoint with the token
    curl -k -H "Authorization: Bearer <token>" \
      https://<scan-hostname>/ords/<DB_NAME>/prom_exporter/prom/v1/metrics
    ```

3. Verify unauthenticated access is now rejected:

    ```bash
    # This should return HTTP 401 Unauthorized
    curl -k -I https://<scan-hostname>/ords/<DB_NAME>/prom_exporter/prom/v1/metrics
    ```

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - German Viscuso, Product Manager, Oracle Autonomous AI Database
- **Last Updated By/Date** - Vandana Rajamani, Consulting UA Developer, June 2026
