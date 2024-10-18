# VAP Concierge Application Setup

Welcome to the **VAP Concierge Application** setup guide. This document provides comprehensive instructions to configure both the client and server devices for running the VAP Concierge application. Please follow the steps carefully to ensure a successful setup.

## Table of Contents

1. [General Explanation](#general-explanation)
2. [Prerequisites](#prerequisites)
3. [Client Device Setup](#client-device-setup)
4. [Server Device Setup](#server-device-setup)

## General Explanation

The **VAP Concierge Application** is designed to run on a network of client-server architecture.

<!-- Need more explanation -->

## Prerequisites

Before proceeding with the setup, ensure you have the following:

- Access to both the client and server devices.
- Network connectivity between client and server devices.

## Client Device Setup

Follow these steps to configure the client device for the VAP Concierge application:

1. **Grant Execute Permissions to the `build_client.sh` Script**

   Open a terminal on the client device and run the following command to grant execute permissions to the `build_client.sh` script:

   ```sh
   chmod +x ./Concierge-VAP/common/build_client.sh
   ```

2. **Execute build script**

   
   ```sh
   ./Concierge-VAP/common/build_client.sh {Github Username} {Github Token}
   ```

   For more information on how to generate a GitHub Token, you can access this [link](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

3. **Activate the Conda Environment**

   Activate the `dds` Conda environment using this 3 command:

   Initialize Conda in your shell environment:
   ```sh
   conda init
   ```
   Reload your shell configuration:
   ```sh
   source ~/.bashrc
   ```
   Activate the dds environment:
   ```sh
   conda activate dds
   ```

   Ensure that all dependencies required by the application are installed within this environment.

4. **Navigate to the Source Directory**

   Change the current directory to the application's source code directory:

   ```sh
   cd /tmp/ramdisk/VAP-Concierge/src
   ```

5. **Run the Client Application**

   Start the client application by executing the server script:

   ```sh
   python server.py > server.log
   ```

   **Note:** Remember to note down the local IP or global IP address of this client device, as it is required for configuring the server device.

## Server Device Setup

Follow these steps to configure the server device:

1. **Grant Execute Permissions to the `build_server.sh` Script**

   Open a terminal on the server device and run the following command:

   ```sh
   chmod +x ./Concierge-VAP/common/build_server.sh
   ```

2. **Execute build script**

   
   ```sh
   ./Concierge-VAP/common/build_server.sh {Github Username} {Github Token} {Client IP}
   ```

   For more information on how to generate a GitHub Token, you can access this [link](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).


3. **Activate the Conda Environment**

   Activate the `dds` Conda environment using this 3 command:

   Initialize Conda in your shell environment:
   ```sh
   conda init
   ```
   Reload your shell configuration:
   ```sh
   source ~/.bashrc
   ```
   Activate the dds environment:
   ```sh
   conda activate dds
   ```

   Ensure that all dependencies required by the application are installed within this environment.

4. **Navigate to the Source Directory**

   Change the current directory to the application's source code directory on the server:

   ```sh
   cd /tmp/ramdisk/VAP-Concierge/src
   ```

5. **Run the Server Configuration Script**

   Execute the server environment test script using bash:

   ```sh
   bash envTest.sh > envTest.log
   ```

   This script will ensure that the server environment is correctly configured and ready to communicate with the client device.

## Conclusion

Following the above steps will set up the VAP Concierge application on both client and server devices. Ensure all IP addresses and configurations are correct. For further assistance, refer to the application's documentation or contact the support team.
