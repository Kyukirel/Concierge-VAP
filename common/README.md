# VAP Concierge Application Setup

Welcome to the **VAP Concierge Application** setup guide. This document provides comprehensive instructions to configure both the client and server devices for running the VAP Concierge application. Please follow the steps carefully to ensure a successful setup.

## Table of Contents

1. [General Explanation](#general-explanation)
2. [Prerequisites](#prerequisites)
3. [Client Device Setup](#client-device-setup)
4. [Server Device Setup](#server-device-setup)

## General Explanation

The **VAP Concierge Application** is designed to run on a network of client-server architecture. The client device is responsible for user interactions and data entry, while the server device processes the data and manages the backend operations. Ensuring both devices are correctly configured is crucial for the application to function effectively.

## Prerequisites

Before proceeding with the setup, ensure you have the following:

- Access to both the client and server devices.
- Necessary permissions to execute scripts on both devices.
- Network connectivity between client and server devices.

## Client Device Setup

Follow these steps to configure the client device for the VAP Concierge application:

1. **Grant Execute Permissions to the `build_client.sh` Script**

   Open a terminal on the client device and run the following command to grant execute permissions to the `build_client.sh` script:

   ```sh
   chmod +x build_client.sh
   ```

2. **Activate the Conda Environment**

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
   python server.py
   ```

   **Note:** Remember to note down the local IP or global IP address of this client device, as it is required for configuring the server device.

## Server Device Setup

Follow these steps to configure the server device:

1. **Grant Execute Permissions to the `build_server.sh` Script**

   Open a terminal on the server device and run the following command:

   ```sh
   chmod +x build_server.sh
   ```

2. **Navigate to the Source Directory**

   Change the current directory to the application's source code directory on the server:

   ```sh
   cd /tmp/ramdisk/VAP-Concierge/src
   ```

3. **Edit Configuration Files**

   Update the necessary configuration files with the client IP address:

   - **`envTest.sh`**: Modify this script to include the client's IP address where applicable.
   - **`run_zharfanf.sh`**: Ensure this script is also updated with the correct client IP address.

4. **Run the Server Configuration Script**

   Execute the server environment test script using bash:

   ```sh
   bash envTest.sh
   ```

   This script will ensure that the server environment is correctly configured and ready to communicate with the client device.

## Conclusion

Following the above steps will set up the VAP Concierge application on both client and server devices. Ensure all IP addresses and configurations are correct. For further assistance, refer to the application's documentation or contact the support team.
