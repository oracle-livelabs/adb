# Install application
## Introduction
This installs the moviestream application
1. Sign in as ADMIN
2. Add workshop utilities
2. Create MOVIESTREAM using common script
3. Add moviestream data using common script
4. Add collections and other objects required by the app 
5. Get the ORDS link and update the config

## Download and install the application code

```
git clone \
  --depth 1  \
  --filter=blob:none  \
  --sparse \
  https://github.com/martygubar/adb.git \
;
cd adb
git sparse-checkout init --cone
git sparse-checkout set shared/moviestream-app

cd MovieStream
npm install
npm run dev

```

## install workshop utilities
  ```
  <copy>
  declare
      l_git varchar2(4000);
      l_repo_name varchar2(100) := 'adb';
      l_owner varchar2(100) := 'martygubar';
      l_package_file varchar2(200) := 'building-blocks/setup/workshop-setup.sql';
  begin
      -- get a handle to github
      l_git := dbms_cloud_repo.init_github_repo(
                  repo_name       => l_repo_name,
                  owner           => l_owner );

      -- install the package header
      dbms_cloud_repo.install_file(
          repo        => l_git,
          file_path   => l_package_file,
          stop_on_error => false);

  end;
  /
  </copy>
  ```

## Create MOVIESTREAM USER
  ```
  <copy>  
  begin
    add_adb_user('moviestream', 'bigdataPM2019#');
  end;
  /

  </copy>
  ```

## Login as MOVIESTREAM and add datasets

  ```
  <copy>
  begin
    workshop.ADD_DATASET(table_names => 'MOVIE,                  
      MOVIESTREAM_CHURN,      
      EXT_POTENTIAL_CHURNERS, 
      GENRE,                  
      CUSTOMER_EXTENSION,     
      TIME,                   
      PIZZA_LOCATION,         
      CUSTOMER_CONTACT,       
      CUSTSALES,              
      CUSTOMER,               
      CUSTOMER_PROMOTIONS,    
      CUSTOMER_SEGMENT,       
      CUSTSALES_PROMOTIONS,   
      JSON_MOVIE_DATA_EXT');
  end;
  /
  </copy>
  ```