# Employee Onboarding Automation System

## Table of Contents
1. [Problem Statement](#problem-statement)
2. [Solution](#solution)
3. [Technologies Used](#technologies-used)
3. [Cloud Architecture](#cloud-architecture)
   - [Overview](#overview)
   - [Key Components](#key-components)
4. [Python FastAPI Application](#python-fastapi-application)
   - [API Endpoints](#api-endpoints)
     - [Employee Endpoints](#employee-endpoints-employeepy)
     - [Department Endpoints](#department-endpoints-departmentpy)
   - [Integration with Azure Infrastructure](#integration-with-azure-infrastructure)
   - [Deployment and Containerization](#deployment-and-containerization)
5. [Automation of User and Group Setup in Microsoft Entra ID](#automation-of-user-and-group-setup-in-microsoft-entra-id)
   - [Step 1: Export Employee Data](#step-1-export-employee-data-from-azure-sql-database)
   - [Step 2: Terraform Code](#step-2-terraform-code-for-user-and-group-creation)
   - [Step 3: Execute Terraform Code](#step-3-execute-terraform-code)
   - [Step 4: Query Azure AD Groups and Members](#step-4-query-azure-ad-groups-and-members)

## Problem Statement

XYZ Corp, a mid-sized company, faces significant challenges in efficiently managing the employee onboarding process. The HR department is responsible for manually tracking new hire details, such as contact information, roles, departments, and equipment needs. This manual process: 

- **Time-consuming**  
- **Error-prone**  
- **Inefficient**, often causing delays in provisioning system access or misplacing critical information.  

HR administrators struggle with fragmented tools, making it difficult to provide a consistent and smooth onboarding experience.

---

## Solution

To address these challenges, I developed an **automated employee onboarding system** leveraging **cloud technologies** with a focus on **Microsoft Entra ID**, **Python**, **Fast API**, **Terraform**  and **Azure services**. The solution:  

- Centralizes employee data.  
- Automates the onboarding workflow.  
- Integrates with Microsoft Entra ID for user provisioning and access management.  

**Key Benefits:**
- **Automatic Account Creation**: Employees gain timely access to systems and resources.  
- **Role-Based Access Control**: Ensures proper permissions.  
- **Hosted on Azure**: Provides a scalable, secure environment.  

This reduces manual intervention, minimizes errors, and enhances the onboarding experience for both employees and HR administrators.

---

## Technologies Used

1. **Azure**   
    - **Use Case**: Azure is used for hosting the application (via Azure App Service), managing the database (via Azure SQL Database), providing secure networking (via Virtual Network), and enabling scalable and secure user management and access (via Microsoft Entra ID). Azure also supports CI/CD pipelines through Azure DevOps, and provides monitoring and diagnostics via Application Insights. For more details, refer to the [Cloud Architecture](#cloud-architecture) section.

2. **Terraform**   
    - **Use Case**: Automates the provisioning and management of resources, including Azure infrastructure and Microsoft Entra ID Users & Groups, ensuring consistent, repeatable deployments.

3. **Python FastAPI**   
    - **Use Case**: Serves as the backend framework for managing employee and department data with robust routing, validation, and ORM capabilities.

4. **Docker**  
    - **Use Case**: Packages the FastAPI application into a container for consistent deployment across environments.

5. **Microsoft Entra ID (Azure AD)**   
    - **Use Case**: Automates user provisioning and role-based access control for employees during onboarding.

6. **Azure DevOps**    
    - **Use Case**: Automates the CI/CD pipeline for building, containerizing, and deploying the FastAPI application and Azure cloud infrastructure to Azure.

7. **SQLAlchemy**   
    - **Use Case**: Facilitates interaction with the Azure SQL Database, mapping database tables to Python objects for streamlined data management.

8. **Bash (SQLCMD)**    
    - **Use Case**: Used to export employee and department data from the Azure SQL Database into a CSV file for Microsoft Entra ID provisioning.

---

## Cloud Architecture

### Overview
This system uses a range of Azure resources to provide a robust infrastructure for an application that involves web services, networking, database integration, and security. Below is an overview of the architecture and how the components interact:

![Screenshot](https://github.com/Jaylon27/Employee-Onboarding-System/blob/ce444554585770f00d3a0bdfd8e0d6a146e08615/screenshots/cloud_employee_system.png)

### Key Components

1. **Azure Virtual Network (VNet)**
- **Purpose**: Provides secure, isolated networking for the application and database.  
- **Subnets**: 
    - **App Subnet:** Hosts the Azure App Service.
    - **Database Subnet:** Hosts the SQL Database with a private endpoint.
    - **Application Gateway Subnet:** Ensures secure traffic routing.

2. **Network Security Groups (NSGs)**
    -  **Purpose:** Control inbound and outbound traffic for the subnets.  
    - **Details:** NSGs are configured for each subnet:
        - **App Subnet NSG:** Allows inbound traffic from the Application Gateway and allows outbound traffic to the database.
        - **App Gateway Subnet NSG:** Ensures secure HTTPS access and allows health check traffic.
        - **Database Subnet NSG:** Restricts access to SQL traffic and allows private endpoint communication.

3. **Azure App Service**
    - **Purpose:** Hosts the application in a Docker container.  
    - **Details:** 
        - The App Service resource manages the app's hosting environment. 
        - Pulls the Docker image from an Azure Container Registry and runs the app in a Linux environment on the Azure App Service.  
    - **Managed Identity:** A system-assigned managed identity is enabled for the app, allowing it to securely access other Azure resources like the SQL Database and Container Registry.

4. **Azure Application Insights**
    - **Purpose:** Provides monitoring and diagnostics for the application.  
    - **Details:** The Application Insights resource tracks the application’s performance and any issues by integrating it into the app’s configuration.

5. **Azure Container Registry**
    - **Purpose:** Stores the Docker image used by the Azure App Service.  
    - **Details:** 
        - The Azure Container Registry is a private registry where the Docker image of the application is stored. T
        - The App Service pulls this image from the registry during deployment.

6. **Azure SQL Database**
    - **Purpose:** Stores data for the application.  
    - **Details:** 
        - The Azure SQL Server and Azure SQL Server resources manage the SQL server and database used by the application. 
        - A private endpoint is set up for secure database access.

7. **Azure Application Gateway**
    - **Purpose:** Acts as a reverse proxy and load balancer for the application.  
    - **Details:** 
        - The Azure Application Gateway is set up with SSL offloading and routing rules to forward traffic to the Azure App Service. 
        - It uses a static public IP for external access and HTTPS for secure connections.

8. **Private Endpoints and DNS**
    - **Purpose:** Ensure secure and private communication between resources.  
    - **Details:** 
        - The Azure Private Endpoint provides secure communication with the SQL database using a private IP address, ensuring that traffic does not traverse the public internet. 
        - A private DNS zone is used to resolve the SQL server's private IP.

The infrastructure for this system is managed using Terraform and deployed automatically via a CI/CD pipeline in Azure DevOps. This pipeline ensures that all resources required for the system are provisioned and managed in a consistent and repeatable manner. 

## Python FastAPI Application

The Python FastAPI application provides a backend for managing employee and department data. It integrates with the Azure cloud infrastructure, utilizing Azure SQL Database for persistent storage and Azure networking components for secure communication. Below is a breakdown of the FastAPI components and their roles in the system:

### API Endpoints

1. **Employee Endpoints (employee.py)**

   - **Create Employee (`POST /employees/`)**: This endpoint allows the creation of new employees. The data is stored in the Azure SQL Database, and after insertion, employee information (such as name, job title, and department) is written to a CSV file for additional processing.
    ```bash
        curl -X 'POST' \
        'https://employeesystem-app-service.azurewebsites.net/employees/' \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d '{
        "first_name": "John",
        "last_name": "Doe",
        "job_title": "Software Engineer Manager",
        "hire_date": "2025-01-05",
        "is_manager": true,
        "department_id": 2
        }'
    ```
   
   - **Get Employee Details (`GET /employees/{employee_id}`)**: Fetches detailed information about an employee based on their ID from the SQL database.
   
   - **Update Employee Details (`PATCH /employees/{employee_id}`)**: Allows updating an employee's details, including first name, last name, position, manager status, and department.
   
   - **Delete Employee (`DELETE /employees/{employee_id}`)**: Deletes an employee record from the database.

2. **Department Endpoints (department.py)**

   - **Create Department (`POST /departments/`)**: This endpoint creates a new department and saves it in the database.
    ```bash
        curl -X 'POST' \
        'https://employeesystem-app-service.azurewebsites.net/departments/' \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d '{
        "name": "Information Technology",
        "created_at": "2025-01-05"
        }'
    ```
   
   - **Get Department Details (`GET /departments/{department_id}`)**: Retrieves detailed information about a department by its ID.
   
   - **Update Department Details (`PATCH /departments/{department_id}`)**: Allows the modification of department details, such as name or manager.
   
   - **Get All Departments (`GET /departments/`)**: Returns a list of all departments in the system.
   
   - **Get Employees in a Department (`GET /department/{department_id}/employees`)**: Lists all employees in a specific department.
   
   - **Delete Department (`DELETE /departments/{department_id}`)**: Deletes a department from the database, provided no employees are assigned to it.

### Integration with Azure Infrastructure

- The application is hosted on Azure App Service within a Docker container, as described in the [Cloud Architecture](#cloud-architecture) section.
  
- The backend communicates with the Azure SQL Database through private endpoints, ensuring secure data access.

### Deployment and Containerization

- To containerize the FastAPI application, a Dockerfile is included, which defines the steps necessary to build and run the application within a Docker container. The Docker container allows the application to run consistently, regardless of where it is deployed.

- The application is deployed through an automated Azure DevOps pipeline, which builds and pushes the Docker image to an Azure Container Registry (ACR) and then deploys it to Azure App Service.

This system forms the backend for employee and department management, with secure and efficient integration into the Azure cloud infrastructure. It is designed for scalability and security, leveraging Azure's managed services like SQL Database, private networking, and App Service.

## Automation of User and Group Setup in Microsoft Entra ID

This project includes an automated process for setting up users in Microsoft Entra ID and associating them with specific groups based on their department. The process involves exporting employee data from an Azure SQL database, then using Terraform to create users and assign them to predefined groups in Microsoft Entra ID. The automation simplifies and accelerates the user provisioning process, ensuring consistency across the organization.

---

### Step 1: Export Employee Data from Azure SQL Database

Administrators can export employee data from the Azure SQL database into a CSV file using the following command:

```bash
sqlcmd \
  -S $SQL_SERVER \
  -U $SQL_USERNAME \
  -P $SQL_PASSWORD \
  -d $SQL_DATABASE \
  -Q "SELECT e.first_name, e.last_name, e.job_title, d.name AS department FROM dbo.employees e JOIN dbo.departments d ON e.department_id = d.id;" \
  -o $FILE_PATH \
  -W \
  -s ","
```
This command queries the employee and department data from the employees table in the Azure SQL database, exporting the information (first name, last name, job title, and department) into a CSV file (users.csv).

---

### Step 2: Terraform Code for User and Group Creation

Once the `users.csv` file is generated, administrators execute the Terraform code to automate the creation of users and their assignment to Microsoft Entra ID groups based on their department.

#### Groups Setup (`groups.tf`)

In this Terraform configuration, the following groups are created:

- **Information Technology (IT)** and **IT Managers** groups
- **Human Resources (HR)** and **HR Managers** groups

#### Users Setup (`users.tf`)

The users are created based on the data from the CSV file. Each user’s `user_principal_name` is generated using their first and last name, followed by a random suffix. The users are assigned to their respective groups according to their department.

#### Sample CSV File (`users.csv`)

The CSV file contains employee data structured with the following columns:

- `first_name`
- `last_name`
- `job_title`
- `department`

#### Sample `users.csv` content:

```csv
first_name,last_name,job_title,department
John,Doe,Software Engineer Manager,Information Technology Managers
Jane,Doe,Instructional Designer Manager,Human Resources Managers
Jack,Doe,Software Engineer,Information Technology
Jill,Doe,Instructional Designer,Human Resources
Morgan,Lee,HR Specialist,Human Resources
Pat,Taylor,HR Manager,Human Resources Managers
Sam,Smith,Cloud Engineer,Information Technology
Alex,Johnson,Cloud Engineer Manager,Information Technology Managers
```

---

### Step 3: Execute Terraform Code
Once the users.csv file is prepared, administrators can run the following Terraform commands to apply the configuration:

Initialize Terraform:
```bash
terraform init
```

Apply the deployment:
```bash
terraform apply
```

### Step 4: Query Azure AD Groups and Members

Once the users are created and assigned to groups, you can verify their membership using Azure CLI commands. Below are examples of queries and their corresponding results.

##### Query Groups
To list the groups in Azure AD that match specific keywords like `Information Technology` or `Human Resources`, use the following commands:

```bash
az ad group list --query "[?contains(displayName, 'Information Technology')].{ name: displayName }" --output tsv
```
```bash
az ad group list --query "[?contains(displayName, 'Human Resources')].{ name: displayName }" --output tsv
```
![Screenshot](https://github.com/Jaylon27/Employee-Onboarding-System/blob/b801ea6b4dd875f19bd90865da47f6775556e32b/screenshots/groups_queries.png)

#### Query Group Members
To list the members of specific groups, such as Information Technology and Human Resources, use the following commands:

```bash
az ad group member list --group "Information Technology" --query "[].{ name: displayName, jobTitle: jobTitle }" --output tsv
```
```bash
az ad group member list --group "Information Technology Managers" --query "[].{ name: displayName, jobTitle: jobTitle }" --output tsv
```

```bash
az ad group member list --group "Human Resources" --query "[].{ name: displayName, jobTitle: jobTitle }" --output tsv
```

```bash
az ad group member list --group "Human Resources Managers" --query "[].{ name: displayName, jobTitle: jobTitle }" --output tsv
```
![Screenshot](https://github.com/Jaylon27/Employee-Onboarding-System/blob/b801ea6b4dd875f19bd90865da47f6775556e32b/screenshots/group_member_queries.png)

