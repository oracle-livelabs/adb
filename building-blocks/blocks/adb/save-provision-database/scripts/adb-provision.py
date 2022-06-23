from oci import config
from oci import database
from oci import identity
from oci import retry
from oci import resource_search
from oci import wait_until
from datetime import datetime
import cx_Oracle
import json
import os
import platform
import sys
import time
from zipfile import ZipFile


# Load the configuration files
# app setup
current_dir = os.path.dirname(os.path.realpath(__file__))
f_json = open(current_dir + '/adb-settings.json')
setup_config = json.load(f_json)

# oci-config
# the setup file specifies which oci configuration to use
oci_config = config.from_file("~/.oci/config", setup_config["oci-config"])

def write_log(msg, msg_type=0):
    msg_prefix = ".............."[0:msg_type * 2]
    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    print (current_time + " : " + msg_prefix + msg)

# return the compartment ocid
def getCompartment():
    # Get the compartment ocid from the adb-config file. 
    # Or, get the ocid from the compartment name if the ocid is blank
    # For both cases, validate the compartment
    
    structured_search = None
    this_query = None
    compartment_id = None

    # build the query that will search for the compartment name or ocid   
    if setup_config["compartment-id"] != "":
        write_log("validating compartment-id", 1)        
        this_query = "query compartment resources where identifier = '" + setup_config["compartment-id"] + "'"     
    else:
        write_log("validating compartment-name '" + setup_config["compartment-name"] + "'", 1)
        this_query = "query compartment resources where name = '" + setup_config["compartment-name"] + "'"                    

    # search for the compartment                                                                                       
    search_client = resource_search.ResourceSearchClient(oci_config)
    structured_search = resource_search.models.StructuredSearchDetails(query=this_query, type='Structured')
    compartments = search_client.search_resources(structured_search)

    # check for the different cases:
    # 1. ocid is in the file - but is not valid
    # 2. compartment name is in the file - but not found in tenancy. Try to create it
    # 3. using the compartment name - but there is more than one with that name (e.g. 2 subcompartments may match)
    # 4. using the compartment name
    if len(compartments.data.items) == 0 and setup_config["compartment-id"] != "":        
        # ocid in the file
        raise Exception('ERROR: invalid compartment id ' + 
                        setup_config["compartment-id"] + 
                        '. Update the setup.json file with a valid compartment name or ocid' )
    elif len(compartments.data.items) == 0 and setup_config["compartment-name"] != "":        
        # a new compartment
        # try to create the compartment name specified in the file
        write_log("trying to create compartment '" + setup_config["compartment-name"] + "'", 1)

        try:
            identity_client = identity.IdentityClient(oci_config)
            compartment_details = identity.models.CreateCompartmentDetails(
                compartment_id = oci_config["tenancy"],
                name = setup_config["compartment-name"],  
                description = "compartment created by moviestream"              
            )
            compartment_response = identity_client.create_compartment (
                compartment_details, 
                retry_strategy = retry.DEFAULT_RETRY_STRATEGY
            )
            
            compartment_id = compartment_response.data.id
            write_log("waiting for compartment " + setup_config["compartment-name"] + " to be created", 1)
            
            time.sleep(5) # must sleep or get_compartment will fail
                        
            compartment = wait_until(identity_client, 
                            identity_client.get_compartment(compartment_id), 
                            'lifecycle_state', 
                            'ACTIVE')
            write_log("compartment " + setup_config["compartment-name"] + " successfully created", 1)

        except Exception as e:            
            raise Exception(e)

    elif len(compartments.data.items) > 1 and setup_config["compartment-name"] != "":
        # compartment name is not unique. you should use an ocid
        msg = "ERROR: more than one compartment named " + setup_config["compartment-name"] + "\n" + "Use a unique compartment name or a compartment ocid"
        raise Exception(msg)
    else:
        # found the compartment!
        compartment_id = compartments.data.items[0].identifier

    return compartment_id     

# create autonomous database
def createDatabase(compartment_id):
    # Create the model and populate the values 
    write_log("trying to create Autonomous Database '" + setup_config["adb-db-name"] + "'", 1)
    db_client = database.DatabaseClient(oci_config)
    adb_details = database.models.CreateAutonomousDatabaseDetails()

    adb_details.compartment_id = compartment_id

    # If free tier, then most config info is not specified
    adb_details.is_free_tier = setup_config["adb-is-free-tier"]
    adb_details.db_name = setup_config["adb-db-name"]
    adb_details.display_name = setup_config["adb-display-name"]
    adb_details.admin_password = setup_config["adb-admin-password"]
    adb_details.db_workload = setup_config["adb-db-workload"]
    
    if adb_details.is_free_tier:
        adb_details.cpu_core_count = 1
        adb_details.data_storage_size_in_tbs = 1
        adb_details.license_model = adb_details.LICENSE_MODEL_LICENSE_INCLUDED

    else:
        adb_details.cpu_core_count = setup_config["adb-ocpu-core-count"]
        adb_details.data_storage_size_in_tbs = setup_config["adb-data-storage-size-in-tbs"]
        adb_details.license_model = setup_config["adb-license-model"]
    
    adb_response = db_client.create_autonomous_database(
        create_autonomous_database_details=adb_details,
        retry_strategy=retry.DEFAULT_RETRY_STRATEGY)

    adb_id = adb_response.data.id
    write_log("waiting for database creation to complete", 1)
    wait_until(db_client, db_client.get_autonomous_database(adb_id), 'lifecycle_state', 'AVAILABLE')
    
    write_log("database created", 1)

    return adb_id

# Downloads the wallet, extracts it and returns the path to the wallet
def get_wallet(adb_id):
    # Single wallet
    wallet_details = database.models.GenerateAutonomousDatabaseWalletDetails()
    wallet_details.generate_type = database.models.GenerateAutonomousDatabaseWalletDetails.GENERATE_TYPE_SINGLE
    wallet_details.password = "welcome1"

    # download it. make the directory if it does not exist
    # the directory name will be "wallet_[db-display-name]"
    wallet_path = current_dir + "/wallet_" + setup_config["adb-display-name"] + "/"
    write_log("creating directory " + wallet_path, 1)
    os.makedirs(wallet_path, exist_ok=True)

    # the file name will be "wallet_[db-display-name].zip" and will be located in the newly created directory
    wallet_file_name = wallet_path + "wallet_" + setup_config["adb-display-name"] + ".zip"

    write_log("requesting the wallet", 1)
    db_client = database.DatabaseClient(oci_config)
    db_response = db_client.generate_autonomous_database_wallet(
        autonomous_database_id=adb_id,
        generate_autonomous_database_wallet_details=wallet_details,
        retry_strategy = retry.DEFAULT_RETRY_STRATEGY
    )
    
    # The zip is in the response content
    wallet_file = open(wallet_file_name, "wb")
    wallet_file.write(db_response.data.content)
    wallet_file.close()

    # extract the zip
    write_log("extracting the connection details from the zip", 1)
    with ZipFile(wallet_file_name, 'r') as zipObj:
        # Extract all the contents of zip file in current directory
        zipObj.extractall(path=wallet_path)

    return wallet_path

def get_connection(tns_admin):
    # Oracle client home
    if platform.system() == "Darwin":
        cx_Oracle.init_oracle_client(
            lib_dir=os.environ.get("HOME")+"/Downloads/instantclient_19_8",
            config_dir=tns_admin
            )

    db_client = database.DatabaseClient(oci_config)

    # Get the database configuration info     
    adb_info = db_client.get_autonomous_database(autonomous_database_id=adb_id)

    # Connection
    adb_conn_string = adb_info.data._connection_strings.medium
    adb_connection = cx_Oracle.connect(
                            "ADMIN", 
                            setup_config["adb-admin-password"],
                            "frompy_medium"
                            )                          

    return adb_connection


if __name__ == "__main__":

    # Get the compartment
    # then, create the database in that compartment
    write_log("begin")
    try:
        
        # Get the compartment
        write_log("get the compartment")
        compartment_id = getCompartment()
        write_log("using compartment with ocid: '" +  compartment_id, 1)

        # Create the database
        write_log("create the database")
        adb_id = createDatabase(compartment_id)
        write_log("created database with ocid: " + adb_id)
        
        # Get the wallet for this new database
        adb_id = "ocid1.autonomousdatabase.oc1.iad.anuwcljs4bv3yyialwn3plka26wk2aw2u7sftkzeltid2xdfrnn7yuorahra"
        #tns_admin = get_wallet(adb_id)
        tns_admin="/Users/mgubar/code/moviestream-demo/setup/wallet_frompy"
        
        # Get the connection
        adb_connection = get_connection(tns_admin)
        print ("connection successful")

        # connect https://oralytics.com/2020/01/28/python-connecting-to-multiple-oracle-autonomous-dbs-in-one-program/

    except Exception as e:
        write_log(str(e))
        write_log("Setup failed. Please review the log above.")


