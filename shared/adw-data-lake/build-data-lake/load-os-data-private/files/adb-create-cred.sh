#!/usr/bin/bash
# oracle cloud infrastructure (oci)
#     identity and access management service (iam)
#
# Build Tag: jenkins-adp-client-tools-26
# Git Commit: 0d98a9f136e92a5cc1acf69f519954012576cdd4

umask 0077

# beginning and ending the aligned output text with a hash, colorized
hashpad() {
    local PALESKYBLUE='\033[38;2;189;246;254m'
    local NC='\033[0m'

    local my_msg="$1"
    shift
    local color_pairs=("$@")

    colorize() {
        local text="$1"
        local word="$2"
        local color="$3"
        printf -v text "${text//$word/${color}${word}${NC}}"
        echo "$text"
    }

    for ((i = 0; i < ${#color_pairs[@]}; i += 2)); do
        word="${color_pairs[i]}"
        color_var="${color_pairs[i + 1]}"
        color="${!color_var}"
        my_msg=$(colorize "$my_msg" "$word" "$color")
    done

    local msg_pln=$(echo -e "$my_msg" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g')
    local msg_len=${#msg_pln}

    local msg_pad="$my_msg"
    while [ "$msg_len" -lt 80 ]; do
        msg_pad="$msg_pad "
        msg_len=$((msg_len + 1))
    done

    printf "# %-80s #\n" "$msg_pad"
}

# generate a string of hashes
hashsep=$(printf '#%.0s' {1..84})

# capture home region from region-subscriptions from specified tenancy
homeregion="$(oci iam region-subscription list --tenancy-id "${OCI_TENANCY}" | \
  jq -r '.data[] | select(."is-home-region"==true)' | jq -r '."region-name"')"

# help flag
display_help() {
    echo
    echo "Usage: $0 [options]" >&2
    echo
    echo "Options:"
    echo "   -h, --help                         Show this help message"
    echo "   -d, --debug                        Enable debug output"
    echo "   -a, --all                          Include all credentials, adds Swift"
    echo "   -r, --region                       Select from a list of regions"
    echo -e "   -r=\033[38;2;189;246;254mREGION\e[0m, --region=\033[38;2;189;246;254mREGION\e[0m         Specify a region"
    echo -e "   -c=\033[38;2;189;246;254mCOMPARTMENT\e[0m, --compartment=\033[38;2;189;246;254mCOMPARTMENT\e[0m"
    echo "                                      Specify a compartment"
    echo
    echo "Example:"
    echo -e "   $0 --region=\033[38;2;189;246;254m${homeregion}\e[0m --compartment=\033[38;2;189;246;254mDevelopment\e[0m"
    echo

    if [ "${all_flag}" = true ]; then
        exit 0
    else
        exit 1
    fi
}

# setting default flag options
help_flag=false
all_flag=false
region_flag=false
region_value=""
compartment_value=""
debug_flag=false

for arg in "$@"
do
    case ${arg} in
        -a|-A|--all|--ALL)
            all_flag=true
            shift
            ;;
        -r|-R|--region|--REGION)
            region_flag=true
            shift
            ;;
        -r=*|-R=*|--region=*|--REGION=*)
            region_flag=true
            region_value="${arg#*=}"
            shift
            ;;
        -c=*|-C=*|--compartment=*|--COMPARTMENT=*)
            compartment_value="${arg#*=}"
            shift
            ;;
        -d|-D|--debug|--DEBUG)
            debug_flag=true
            shift
            ;;
        -h|-H|--help|--HELP)
            help_flag=true
            shift
            ;;
        *)
            echo -e "\n${hashsep}"
            hashpad "The option you chose does not exist. Please use one of the supported options."
            echo "${hashsep}"
            display_help
    esac
done

if $debug_flag; then
    echo "all_flag: $all_flag"
    echo "region_flag: $region_flag"
    echo "region_value: $region_value"
    echo "compartment_value: $compartment_value"
    echo "debug_flag: $debug_flag"
    echo "help_flag: $help_flag"
fi

if [ "$help_flag" = true ]; then
    display_help
fi

# handle control-c
handle_ctrlc() {
    echo -e "\n\n${hashsep}"
    hashpad "This script was abruptly terminated with Ctrl-C" "Ctrl-C" "PALESKYBLUE"
    echo -e "${hashsep}"
    end_of_script
}

# end of script
end_of_script() {
    if [ "${all_flag}" = true ]; then
        echo -e "\nTo view PL/SQL script for creating credentials,\n\n\texecute: \033[38;2;189;246;254mcat ~/oci_native_credential.sql\e[0m\n\texecute: \033[38;2;189;246;254mcat ~/oci_auth_token_credential.sql\e[0m\n"
    else
        echo -e "\nTo view PL/SQL script for creating credentials,\n\n\texecute: \033[38;2;189;246;254mcat ~/oci_native_credential.sql\e[0m\n"
    fi
    exit 0
}

# setting the region value
if [ "$region_flag" = true ] && [ -n "$region_value" ] && [ "$(oci iam region list --all | jq -r '.data[] | select(."name"=="'"${region_value,,}"'") | ."name"')" == "${region_value,,}" ]; then
    echo -e "\nYou specified the Region [\033[38;2;189;246;254m""${region_value}""\e[0m]"
elif [ "$region_flag" = true ] && [ -n "$region_value" ]; then
    echo -e "\n${hashsep}"
    hashpad "You specified an invalid Region, ignoring selection."
    echo "${hashsep}"
    region_value=""
else
    region_value=""
fi

# setting the compartment value
if [ -n "$compartment_value" ] && [ "$(oci iam compartment list --all | jq -r '.data[] | select(."name"=="'"${compartment_value}"'") | ."name"')" == "${compartment_value}" ]; then
    echo -e "\nYou specified the Compartment [\033[38;2;189;246;254m""${compartment_value}""\e[0m]"
elif [ -n "$compartment_value" ]; then
    echo -e "\n${hashsep}"
    hashpad "You specified an invalid Compartment, ignoring selection."
    echo "${hashsep}"
    compartment_value=""
else
    compartment_value=""
fi

# uniquely tag backups with date and append random 3 letter/number string
bkptag=bkp_"$(date +%Y%m%d)"_"$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 3)"

# handle federated identity provider
if [[ "${OCI_CS_USER_OCID}" == *'saml2'*'@'* ]]; then
    myuserocid=$(oci --region "${homeregion}" iam user list --all | jq -r '.data[] | select(.name == "'"$(oci \
      --region "${homeregion}" iam identity-provider list --compartment-id "${OCI_TENANCY}" \
      --protocol SAML2 | jq -r '.data[] | select(."id"=="'"${OCI_CS_USER_OCID%%/*}"'") | .name' | \
      tr '[:upper:]' '[:lower:]')"'/'"${OCI_CS_USER_OCID##*/}"'") | .id')
else
    myuserocid="${OCI_CS_USER_OCID}"
fi

### NATIVE CREDENTIAL

# generate api private & public keys using oci setup config which also generates fingerprint
generate_api_keys() {
    mkdir -p "${HOME}"/.oci
    openssl genrsa -out "${HOME}"/.oci/oci_api_key.pem 2048 > /dev/null 2>&1
    echo -e "\nYour Private API Key was generated with a key length of \033[38;2;189;246;254m2048\e[0m bits."
    openssl rsa -pubout -in "${HOME}"/.oci/oci_api_key.pem -out "${HOME}"/.oci/oci_api_key_public.pem > /dev/null 2>&1
    echo -e "\nYour Public API Key was generated.\n"
    echo -e "\n${myuserocid}\n${OCI_TENANCY}\n${homeregion}\nn\n${HOME}/.oci/oci_api_key.pem\n" | \
      oci setup config > /dev/null 2>&1
    echo -e "Your Fingerprint was generated."
}

# generate public key then upload to profile
upload_api_keys() {
    if [[ ! -f "${HOME}"/.oci/oci_api_key_public.pem ]]; then
        openssl rsa -pubout -in "$(awk -F'key_file=' '/key_file=/ {print $2}' "${HOME}"/.oci/config)" \
        -out "${HOME}"/.oci/oci_api_key_public.pem > /dev/null 2>&1
        echo -e "\nYour Public API Key was generated."
    fi
    oci --region "${homeregion}" iam user api-key upload --user-id "${myuserocid}" \
      --key-file "${HOME}"/.oci/oci_api_key_public.pem > /dev/null 2>&1
    echo -e "\nYour API key was uploaded to your Profile."
}

# check oci profile for fingerprint then upload public key if necessary
check_oci_profile() {
    if [[ "$(oci --region "${homeregion}" iam user api-key list --user-id "${myuserocid}" --all | \
               grep -c "$(grep '^fingerprint=' "${HOME}"/.oci/config | sed -e 's/^fingerprint=//')")" -eq 2 ]]; then
        echo -e "\nYour API Key was NOT removed, it was found in your OCI Profile. Let's use it!"
    else
        echo -e "\nYour API Key was NOT removed, however, it's not in your OCI Profile. We got this!"
        upload_api_keys
    fi
}

echo -e "\n${hashsep}"
hashpad "This initial step ensures your OCI API Keys and Fingerprint are setup properly."
echo "${hashsep}"

if [[ -f "${HOME}"/.oci/config ]]; then
    echo "" ; read -rp $'You have an existing API Key and Fingerprint! Do you want to try to reuse them? (\033[38;2;189;246;254my\033[0m/n): ' answer
    answer=${answer:-y}
    if [[ "${answer,,}" =~ ^(y|yes)$ ]]; then
        check_oci_profile
    else
        echo "" ;
        echo -e "WARNING: If you replace your API Key and Fingerprint, they will no longer work for any users or credentials.\n"
        read -rp $'Do you want to replace them anyway? (y/\033[38;2;189;246;254mn\033[0m): ' answer
        answer=${answer:-n}

        if [[ "${answer,,}" =~ ^(y|yes)$ ]]; then
            if [[ -n "$(grep '^fingerprint=' "${HOME}"/.oci/config | sed -e 's/^fingerprint=//')" ]]; then
                # remove api key from your profile
                oci --region "${homeregion}" iam user api-key delete \
                  --fingerprint "$(grep '^fingerprint=' "${HOME}"/.oci/config | \
                  sed -e 's/^fingerprint=//')" --user-id "${myuserocid}" --force  > /dev/null 2>&1
                echo -e "\nYour API Key was removed from your Profile."
            fi
            # backup oci directory, move
            mv "${HOME}"/.oci "${HOME}"/.oci_"${bkptag}"
            echo -e "\nYour old OCI directory file was backed up to [\033[38;2;189;246;254m~/.oci_""${bkptag}""\e[0m]."
            echo -e "\nYour API Key was removed from this Cloud Shell."
            generate_api_keys
            upload_api_keys
        else
            echo -e "No changes made."
            exit
        fi
    fi
else
    generate_api_keys
    upload_api_keys
fi

# generate oci_native_credential.sql
echo -e "SET FEEDBACK OFF;\n\nBEGIN\n\tDBMS_CLOUD.DROP_CREDENTIAL(\n\t\tcredential_name => 'OCI_NATIVE_CRED');\nEXCEPTION WHEN OTHERS THEN NULL;\nEND;\n/\n\n\
BEGIN\n\tDBMS_CLOUD.CREATE_CREDENTIAL(\n\t\tcredential_name => 'OCI_NATIVE_CRED',\n\t\tuser_ocid => '${myuserocid}',\
\n\t\ttenancy_ocid => '${OCI_TENANCY}',\n\t\tprivate_key => '""$(tr -d '\n' < "$(awk -F'key_file=' '/key_file=/ {print $2}' "${HOME}"/.oci/config)" | \
sed 's/-----BEGIN PRIVATE KEY-----//;' | sed 's/-----END PRIVATE KEY-----//;')""',\n\t\tfingerprint => '""$(grep '^fingerprint=' "${HOME}"/.oci/config | \
sed -e 's/^fingerprint=//')""');\nEND;\n/\n\n\nprompt "Attention: OCI Native Credential was applied...";\nexit;" | \
expand -t 2 > "${HOME}"/oci_native_credential.sql

echo -e "\nYour Native Credential SQL file [\033[38;2;189;246;254m~/oci_native_credential.sql\e[0m] was created.\n"

# generate oci_native_credential.json
echo -e '{\n    "name": "OCI_JSON_NATIVE_CRED",\n    "credtype": "Oracle.OCI.Auth",\n    "columnValues": {\n\t"user": "'"${myuserocid}"\
'",\n\t"private_key": "'"$(tr -d '\n' < "$(awk -F'key_file=' '/key_file=/ {print $2}' "${HOME}"/.oci/config)" | \
sed 's/-----BEGIN PRIVATE KEY-----//;' | sed 's/-----END PRIVATE KEY-----//;'
)"'",\n\t"fingerprint": "'"$(grep '^fingerprint=' "${HOME}"/.oci/config | \
sed -e 's/^fingerprint=//')"'",\n\t"tenancy": "'"${OCI_TENANCY}"'"\n    }\n}' > "${HOME}"/oci_native_credential.json

echo -e "Your Native Credential JSON file [\033[38;2;189;246;254m~/oci_native_credential.json\e[0m] was created.\n"

trap 'handle_ctrlc' SIGINT

### AUTHTOKEN

if [ "${all_flag}" = true ]; then

    sql_file_auth_token() {
        # capture the user's name
        myauthusername="$(oci --region "${homeregion}"  iam user get --user-id "${myuserocid}"|jq -r '.data.name')"
        myauthtoken="$(jq -r '.data."token"' < "${HOME}"/auth_token.tok)"
        myauthtokensc=${myauthtoken//\'/\'\'}
        echo -e "SET FEEDBACK OFF;\n\nBEGIN\n\tDBMS_CLOUD.DROP_CREDENTIAL(\n\t\tcredential_name => 'OCI_AUTH_TOKEN_CRED');\nEXCEPTION WHEN OTHERS THEN NULL;\nEND;\n/\n\n\
        BEGIN\n\tDBMS_CLOUD.CREATE_CREDENTIAL(\n\t\tcredential_name => 'OCI_AUTH_TOKEN_CRED',\n\t\tusername => '${myauthusername}',\
        \n\t\tpassword => '${myauthtokensc}');\nEND;\n/\n\n\nprompt "Attention: API AuthToken was applied...";\nexit;" | \
        expand -t 2 > "${HOME}"/oci_auth_token_credential.sql
        echo -e "\nYour AuthToken SQL file [\033[38;2;189;246;254m~/oci_auth_token_credential.sql\e[0m] was created.\n"
    }

    create_auth_token() {
        oci --region "${homeregion}" iam auth-token create --description oci-auth-token \
          --user-id "${myuserocid}" > auth_token.tok
        echo -e "\nYour AuthToken was generated and uploaded. Output retained in [\033[38;2;189;246;254m~/auth_token.tok\e[0m]."
        sql_file_auth_token
        echo -e "${hashsep}"
        hashpad "Store AuthToken in a safe & secure location, it's not visible in OCI Management."
        gen_auth_token=y
        echo -e "${hashsep}\n"
    }

    keep_auth_token() {
        if [[ -f "${HOME}"/auth_token.tok ]]; then
            echo -e "\nYour AuthToken named [\033[38;2;189;246;254moci-auth-token\e[0m] was NOT removed. Let's use it!"
            sql_file_auth_token
            gen_auth_token=y
        else
            echo -e "\nAlthough you have an AuthToken [\033[38;2;189;246;254moci-auth-token\e[0m] we cannot locate your AuthToken file, therefore we cannot use it.\n"
            gen_auth_token=n
        fi
        echo -e "${hashsep}\n"
    }

    echo -e "${hashsep}"
    hashpad "Most authentication requirements are typically met by the OCI Native Credential."
    hashpad "However, in some situations where the Native Credential is not compatible, the"
    hashpad "AuthToken serves as an alternative. This next step will generate the AuthToken."
    echo -e "${hashsep}\n"

    if [[ -n $(oci --region "${homeregion}" iam auth-token list --user-id "${myuserocid}" | jq -r '.data[] | select(."description"=="oci-auth-token") | .id') ]]; then
        read -rp $'You have an AuthToken named [\033[38;2;189;246;254moci-auth-token\033[0m]. Do you want to reuse it?  (\033[38;2;189;246;254my\033[0m/n): ' answer
        answer=${answer:-y}
        if [[ "${answer,,}" =~ ^(y|yes)$ ]]; then
            keep_auth_token
        else
            echo ""
            echo -e "WARNING: If you replace your AuthToken [\033[38;2;189;246;254moci-auth-token\033[0;0m], it will no longer work for any users or credentials.\n"
            read -rp $'Do you want to replace it anyway? (y/\033[38;2;189;246;254mn\033[0m): ' answer
            answer=${answer:-n}
            if [[ "${answer,,}" =~ ^(y|yes)$ ]]; then
                if [[ -f "${HOME}"/auth_token.tok ]]; then
                    # backup authtoken file, move
                    mv "${HOME}"/auth_token.tok "${HOME}"/auth_token.tok_"${bkptag}"
                    echo -e "\nYour old AuthToken file was backed up to [\033[38;2;189;246;254m~/auth_token.tok_""${bkptag}""\e[0m]."
                fi
                oci --region "${homeregion}" iam auth-token delete --auth-token-id "$(oci \
                  --region "${homeregion}" iam auth-token list --user-id "${myuserocid}" | \
                jq -r '.data[] | select(."description"=="oci-auth-token") | .id')" --user-id "${myuserocid}" --force
                echo -e "\nDeleted old AuthToken named [\033[38;2;189;246;254moci-auth-token\e[0m] from your Profile."
                create_auth_token
            fi
        fi
    else
        read -rp $'Would you like to include an AuthToken? (\033[38;2;189;246;254my\033[0m/n): ' answer
        answer=${answer:-y}
        if [[ "${answer,,}" =~ ^(y|yes)$ ]]; then
            create_auth_token
        else
            gen_auth_token=n
        fi
    fi
else
    echo -e "${hashsep}\n"
fi

### AUTONOMOUS DATABASE

# generate wallet zip file with bogus password and fix sqlnet directory path
setup_wallet_location() {
    oci --region "${myregion}" db autonomous-database generate-wallet \
      --autonomous-database-id "$(oci --region "${myregion}" db autonomous-database list \
      --compartment-id "$(oci --region "${myregion}" iam compartment list --all --include-root | \
      jq -r '.data[] | select(.name=="'"${v_compartment}"'") | .id')" | \
      jq -r '.data[] | select(."db-name"=="'"${v_database}"'") | .id')" \
      --password FooBar_12345 --file "${v_database}"_wallet.zip > /dev/null 2>&1

    if [[ -d "${HOME}/${v_database}_wallet" ]]; then
        # backup wallet directory, move
        mv "${HOME}"/"${v_database}"_wallet "${HOME}"/"${v_database}"_wallet_"${bkptag}"
        echo -e "\nYour old Wallet folder was backed up to [\033[38;2;189;246;254m~/${v_database}_wallet_${bkptag}\e[0m]."
    fi

    mkdir "${HOME}"/"${v_database}"_wallet

    if [[ -f "${HOME}/${v_database}_wallet.zip" ]]; then
        unzip "${HOME}"/"${v_database}"_wallet.zip -d "${HOME}"/"${v_database}"_wallet  > /dev/null 2>&1
        rm "${HOME}"/"${v_database}"_wallet.zip
    fi
}

# fix the wallet directory path in the SQLNet.ora file
fix_sqlnet_file() {
    if [ -f "${HOME}/${v_database}_wallet/sqlnet.ora" ]; then
        if grep -q 'DIRECTORY="?/network/admin"' "${HOME}/${v_database}_wallet/sqlnet.ora"; then
            echo -e "\nFixing path in [\033[38;2;189;246;254m~/${v_database}_wallet/sqlnet.ora\e[0m] to that of your Wallet File."
            sed -i.bak "s|(DIRECTORY=\"?/network/admin\")|(DIRECTORY=\"""${HOME}""/""${v_database}""_wallet\")|g" "${HOME}"/"${v_database}"_wallet/sqlnet.ora
            return 0
        fi
    else
        return 1
    fi
}

# step through compartments and autonomous databases and run credential script/s
adb_error_handling() {
    if [ "${all_flag}" = true ]; then
        hashpad "Unfortunately, these scripts cannot be executed in your Autonomous Database."
        hashpad "Please consider running ~/oci_native_credential.sql and" "~/oci_native_credential.sql" "PALESKYBLUE"
        hashpad "~/oci_auth_token_credential.sql using your own SQL client." "~/oci_auth_token_credential.sql" "PALESKYBLUE"
    else
        hashpad "Unfortunately, this script cannot be executed in your Autonomous Database."
        hashpad "Please consider running ~/oci_native_credential.sql using your own SQL Client." "~/oci_native_credential.sql" "PALESKYBLUE"
    fi
}

### REGION PROCESSING

reg_processing() {
    declare -A regMap
    index=1

    echo -e "\nRegions you have access to:\n"

    for v_region_name in $(oci iam region list --all | jq -r '.data[] | ."name"' | sort); do
        if [ "${homeregion}" == "${v_region_name}" ]; then
            echo -e "\033[38;2;189;246;254m${index}) ${v_region_name}\e[0m"
        else
            echo "${index}) ${v_region_name}"
        fi
        regMap["${index}"]="${v_region_name}"
        ((index++))
    done

    echo -e "\n\033[38;2;189;246;254m* Home Region\e[0m\n"
    read -rp "Select the number pertaining to the Region you would like to use: " choice

    myregion="${regMap["${choice}"]}"

    if [[ -z "${myregion}" ]]; then
        echo -e "\nInvalid selection, please run this again.\n"
        exit 1
    else
        echo -e "\nYou have selected the Region [\033[38;2;189;246;254m${myregion}\e[0m]"
    fi
}

# if the shell region does not match home region
reg_check() {
    if [ "$region_flag" = true ] && [ -n "$region_value" ]; then
        myregion="${region_value}"
        #echo -e "\nYou have defined your region using the region flag [\033[38;2;189;246;254m${myregion}\e[0m]"
    else
        if [ "${region_flag}" = true ]; then
            reg_processing
        else
            if [[ "${homeregion}" != "${OCI_REGION}" ]] || [[ "${homeregion}" != "${OCI_CLI_PROFILE}" ]]; then
                echo -e "\n${hashsep}"
                hashpad "REGION WARNING: Choosing the correct Region is crucial to accessing available " "REGION WARNING:" "PALESKYBLUE"
                hashpad "resources, such as Compartments and Autonomous Databases."
                hashpad ""
                hashpad "Current Region [""${OCI_REGION}""] does not match Home Region [""${homeregion}""]" ""${OCI_REGION}"" "PALESKYBLUE" ""${homeregion}"" "PALESKYBLUE"
                echo "${hashsep}"
                echo "" ; read -rp $'Do you want to \e[1m(k)\e[0meep current region, change to \e[1m(h)\e[0mome or \e[1m(p)\e[0mick a different one? (\033[38;2;189;246;254mk\033[0m/h/p): ' answer
                answer=${answer:-k}
                if [[ "${answer,,}" =~ ^(p|pick)$ ]]; then
                    reg_processing
                elif [[ "${answer,,}" =~ ^(k|keep)$ ]]; then
                    myregion="${OCI_REGION}"
                   echo -e "\nYou have kept your current region [\033[38;2;189;246;254m${myregion}\e[0m]"
                else
                    echo "" ; read -rp $'WARNING: This action will adjust the script to use your home region instead. Proceed? (y/\033[38;2;189;246;254mn\033[0m): ' answer
                    answer=${answer:-n}
                    if [[ "${answer,,}" =~ ^(y|yes)$ ]]; then
                        myregion="${homeregion}"
                        echo -e "\nYou have selected your home region [\033[38;2;189;246;254m${myregion}\e[0m]"
                    else
                        myregion="${OCI_REGION}"
                        echo -e "\nYou have kept your current region [\033[38;2;189;246;254m${myregion}\e[0m]"
                    fi
                fi
            else
                myregion="${OCI_REGION}"
            fi
        fi
    fi
}

is_adb_pe() {
    if [ -n "$(oci db autonomous-database --region "${myregion}" list --compartment-id "${tmp_compartment}" | jq -r '.data[] | select(."db-name"=="'"${v_database}"'") | ."private-endpoint"')" ] && [ "$(oci db autonomous-database --region "${myregion}" list --compartment-id "${tmp_compartment}" | jq -r '.data[] | select(."db-name"=="'"${v_database}"'") | ."private-endpoint"')" != "null" ]; then
        adb_pe=true
    else
        adb_pe=false
    fi
}

adb_processing() {

    declare -A adbMap
    index=1

    if [ -n "$compartment_value" ]; then

        tmp_compartment="$(oci --region "${myregion}" iam compartment list --all \
          --include-root | jq -r '.data[] | select(."name"=="'"${compartment_value}"'") | .id')"
        my_cmpt_adw_cnt="$(oci --region "${myregion}" db autonomous-database list --all \
          --compartment-id "${tmp_compartment}" | jq -r '.data[] ."display-name"' | wc -l)"

        if [ "${my_cmpt_adw_cnt}" -eq 0 ]; then
            echo -e "${hashsep}"
            hashpad "This Compartment does not contain ADBs in the Region [""${myregion}""]" ""${myregion}"" "PALESKYBLUE"
            echo -e "${hashsep}\n"
            return
        fi

    else

        echo -e "\n${hashsep}"
        hashpad "May take time to gather Compartments & Autonomous Databases on a large Tenancy."
        echo -e "${hashsep}\n"

        echo -e "Compartments within Region [\033[38;2;189;246;254m""${myregion}""\e[0m] that may have Autonomous Databases:\n"

        my_adw_cnt=0
        my_cmpt_adw_cnt=0

        for v_cmprtmnt_ocid in $(oci --region "${myregion}" iam compartment list --all --include-root | jq -r '.data[] | .id');
        do
            my_adw_cnt=$(oci --region "${myregion}" db autonomous-database list --all \
              --compartment-id "${v_cmprtmnt_ocid}" | jq -r '.data[] ."display-name"' | wc -l)
            if [[ "${my_adw_cnt}" -gt 0 ]]; then
                echo "${index}) $(oci --region "${myregion}" iam compartment get --compartment-id "${v_cmprtmnt_ocid}" | jq -r '.data.name' | sort)"
                adbMap["${index}"]="${v_cmprtmnt_ocid}"
                ((index++))
            fi

            my_cmpt_adw_cnt="$((my_cmpt_adw_cnt+my_adw_cnt))"

        done

        if [ "${my_cmpt_adw_cnt}" -eq 0 ]; then
            echo -e "${hashsep}"
            hashpad "There are no Compartments containing ADBs in the Region [""${myregion}""]." ""${myregion}"" "PALESKYBLUE"
            echo -e "${hashsep}\n"
            return
        fi

        echo "" ; read -rp "Select the number pertaining to your Compartment: " choice

        tmp_compartment="${adbMap["${choice}"]}"

        if [[ -z "${tmp_compartment}" ]]; then
            echo -e "Invalid selection, please run this again.\n"
            exit 1
        fi

    fi

    echo -e "\nAutomomous Databases within Region [\033[38;2;189;246;254m""${myregion}""\e[0m] in Compartment [\033[38;2;189;246;254m""$(oci \
      --region "${myregion}" iam compartment get --compartment-id "${tmp_compartment}" | \
      jq -r '.data.name')""\e[0m]:\n"
    PS3=$'\n'"Select the number pertaining to your Autonomous Database: "

    select v_display_name in $(oci --region "${myregion}" db autonomous-database list --compartment-id "${tmp_compartment}" --all | jq -r '.data[] ."display-name"' | sort);
    do
        v_database="$(oci --region "${myregion}" db autonomous-database list --compartment-id "${tmp_compartment}" \
          --all | jq -r '.data[] | select(."display-name" == "'"${v_display_name}"'") | ."db-name"')"
        is_adb_pe
        if [[ -n "${v_database}" && "${adb_pe}" == "false" ]]; then
            v_compartment=$(oci --region "${myregion}" iam compartment get --compartment-id "${tmp_compartment}" | jq -r '.data.name')
            if [[ -f "${HOME}"/"${v_database}"_wallet/tnsnames.ora ]]; then
                echo "" ; read -rp $'You have an existing Wallet File for [\033[38;2;189;246;254m'"${v_display_name}"$'\033[0m]. Do you want to reuse it? (\033[38;2;189;246;254my\033[0m/n): ' answer
                answer=${answer:-y}
                if [[ "${answer,,}" =~ ^(n|no)$ ]]; then
                    echo "" ; read -rp $'WARNING: This action will replace your Wallet File. Proceed? (y/\033[38;2;189;246;254mn\033[0m): ' answer
                    answer=${answer:-n}
                    if [[ "${answer,,}" =~ ^(y|yes)$ ]]; then
                        setup_wallet_location
                    fi
                fi
            else
                echo -e "\nYou do not have a Wallet File. Let's set it up for you."
                setup_wallet_location
            fi

            if ! fix_sqlnet_file; then
                echo -e "\n${hashsep}"
                hashpad "There was an error processing the SQLNet.ora file in your wallet location." "SQLNet.ora" "PALESKYBLUE"
                adb_error_handling
                echo -e "${hashsep}\n"
                break
            fi

            echo -e "\n${hashsep}"
            hashpad "We setup your credentials, generated SQL scripts to add the credentials, we"
            hashpad "also setup your Autonomous Database connection, and are now connecting you to"
            hashpad "your Autonomous Database so you can execute the credential scripts."
            echo -e "${hashsep}\n"

            export TWO_TASK="${v_database,,}"_high
            export TNS_ADMIN="${HOME}"/"${v_database}"_wallet
            loginattempt=0
            max_attempts=3

            while [ "${loginattempt}" -lt "${max_attempts}" ]; do
                read -rp "Enter Autonomous Database username: " adbusr
                echo "Enter Autonomous Database password: "
                read -rs adbpwd
                echo ""
                sqloutput=$(echo -e "${adbusr}\n${adbpwd}\nSELECT 1 FROM DUAL;\nexit;\n" | sql 2>&1)
                got_error=n
                case "${sqloutput}" in
                    *"ORA-"*)
                        if [ "${debug_flag}" = true ]; then
                            echo -e "\033[38;2;189;246;254m$(echo "${sqloutput}" | grep -o 'ORA-[0-9]\{5\}[:|,].*')\e[0m"
                        fi
                        got_error=y
                        ;;
                    *"Error"*)
                        if [ "${debug_flag}" = true ]; then
                            echo -e "\033[38;2;189;246;254m$(echo "${sqloutput}" | grep -o 'Error.*')\e[0m"
                        fi
                        got_error=y
                        ;;
                    *) ;;
                esac
                if [[ ${got_error} == 'y' ]]; then
                    loginattempt=$((loginattempt+1))
                    echo -e "Login attempt ""${loginattempt}"" of ""${max_attempts}"".\n"
                    if [[ "${loginattempt}" -eq "${max_attempts}" ]]; then
                        echo -e "${hashsep}"
                        hashpad "You've exceeded the maximum number of login attempts! To attempt this again,"
                        hashpad "copy SQL script/s into the tool you use to connect to your Autonomous Database."
                        echo -e "${hashsep}\n"
                        exit 1
                    fi

                else
                    echo "Login successful."
                    cred_sqlout=$(echo -e "${adbusr}\n${adbpwd}\n@${HOME}/oci_native_credential.sql\nexit;\n" | sql 2>&1)
                    cred_got_error=n
                    case "${cred_sqlout}" in
                        *"ORA-"*)
                            cred_got_error=y
                            ;;
                        *"Error"*)
                            cred_got_error=y
                            ;;
                        *) ;;
                    esac

                    if [[ ${cred_got_error} == 'y' ]]; then
                        echo -e "\n${hashsep}"
                        hashpad "There was an error while creating the credential for this user."
                        adb_error_handling
                        echo -e "${hashsep}\n"
                        break
                    fi

                    echo -e "\nOCI Native Credential [\033[38;2;189;246;254mOCI_NATIVE_CRED\e[0m] creation successful."

                    if [ "${all_flag}" = true ]; then
                        if [[ "${gen_auth_token,,}" =~ ^(y|yes)$ ]] && [[ -f "${HOME}"/auth_token.tok ]]; then
                            auth_sqlout=$(echo -e "${adbusr}\n${adbpwd}\n@${HOME}/oci_auth_token_credential.sql\nexit;\n" | sql 2>&1)
                            auth_got_error=n
                            case "${auth_sqlout}" in
                                *"ORA-"*)
                                auth_got_error=y
                                ;;
                            *"Error"*)
                                auth_got_error=y
                                ;;
                            *) ;;
                            esac

                            if [[ ${auth_got_error} == 'y' ]]; then
                                echo -e "\n${hashsep}"
                                hashpad "There was an error while creating the credential for this user."
                                adb_error_handling
                                echo -e "${hashsep}\n"
                                break
                            fi

                        echo -e "\nAuthToken Credential [\033[38;2;189;246;254mOCI_AUTH_TOKEN_CRED\e[0m] creation successful."

                        fi

                    fi

                    break
                fi
            done
            if [[ ${cred_got_error} == 'n' ]]; then
                echo -e "\n${hashsep}"
                hashpad "Please be aware that it may take up 15 minutes to propagate your credentials to"
                hashpad "OCI Services. During this period of time your new credentials will not work."
                echo -e "${hashsep}\n"
            fi
            break
        elif [[ -n "${v_database}" && "${adb_pe}" == "true" ]]; then
            echo -e "\nYour Autonomous Database is in a Virtual Cloud Network. Connecting here will fail.\n"
            if [ "${all_flag}" = true ]; then
                echo -e "Execute contents of \033[38;2;189;246;254mcat ~/oci_native_credential.sql\e[0m and \033[38;2;189;246;254m~/oci_auth_token_credential.sql\e[0m in a SQL Client connected via Bastion or Jump Host.\n"
            else
                echo -e "Execute contents of \033[38;2;189;246;254m~/oci_native_credential.sql\e[0m in a SQL Client connected via Bastion or Jump Host.\n"
            fi
            break
        else
            echo -e "\n\nInvalid selection, please pick a valid number from the list.\n"
        fi
    done
}

# run credential scripts in autonomous databases
firstgo=y

while true; do
    if [[ "${firstgo}" == y ]]; then
        read -rp $'Proceed to run the Credential Scripts on your Autonomous Database? (y/\033[38;2;189;246;254mn\033[0m): ' answer
        answer=${answer:-n}
    else
        read -rp $'Proceed to run the Credential Scripts on \033[38;2;189;246;254manother\033[0m Autonomous Database? (y/\033[38;2;189;246;254mn\033[0m): ' answer
        answer=${answer:-n}
    fi
    case "${answer,,}" in
        y|yes)
            reg_check
            adb_processing
            firstgo=n
            ;;
        n|no)
            echo -e "\nExiting..."
            break
            ;;
        *)
            echo -e "\nInvalid selection, please type 'y' or 'n'\n"
            ;;
    esac
done

end_of_script