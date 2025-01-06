# Problem Statement

XYZ Corp, a mid-sized company, faces significant challenges in efficiently managing the employee onboarding process. The HR department is responsible for manually tracking new hire details, such as contact information, roles, departments, and equipment needs. This manual process is time-consuming, error-prone, and often results in delays, such as misplacing critical information or failing to provision necessary system access in a timely manner. HR administrators are burdened with manually entering and verifying data, and onboarding tasks are fragmented across various tools, making it difficult to provide a smooth and consistent experience for new hires.

# Solution

To address these inefficiencies, I developed an automated employee onboarding system leveraging cloud technologies, with a particular focus on Microsoft Entra ID and Azure services. The platform centralizes employee data, automates the onboarding workflow, and integrates seamlessly with Microsoft Entra ID for user provisioning and access management. This integration enables the automatic creation of employee accounts and role-based access control, ensuring that new hires gain access to the right systems and resources as soon as possible. Hosted on Azure, the solution provides a scalable, secure environment for managing the entire onboarding process. By reducing manual intervention, minimizing errors, and automating administrative tasks, the application streamlines the onboarding process, saving time and improving the experience for both new hires and HR administrators.

# Cloud Architecture

This project uses a range of Azure resources to provide a robust infrastructure for an application that involves web services, networking, database integration, and security. Below is an overview of the architecture and how the components interact:

## Key Components

### 1. Azure Virtual Network (VNet)
**Purpose:** Provides secure, isolated networking for the application and database.  
**Details:** The `azurerm_virtual_network` resource ensures all services (app service, database, etc.) communicate securely within a private network. The VNet includes multiple subnets:
- **App Subnet:** Hosts the Azure App Service.
- **Database Subnet:** Hosts the SQL Database with a private endpoint.
- **Application Gateway Subnet:** Ensures secure traffic routing.

### 2. Network Security Groups (NSGs)
**Purpose:** Control inbound and outbound traffic for the subnets.  
**Details:** NSGs are configured for each subnet:
- **App Subnet NSG:** Allows inbound traffic from the Application Gateway and allows outbound traffic to the database.
- **App Gateway Subnet NSG:** Ensures secure HTTPS access and allows health check traffic.
- **Database Subnet NSG:** Restricts access to SQL traffic and allows private endpoint communication.

### 3. Azure App Service
**Purpose:** Hosts the application in a Docker container.  
**Details:** The `azurerm_app_service` resource manages the app's hosting environment. It pulls the Docker image from an Azure Container Registry (`azurerm_container_registry`) and runs the app in a Linux environment on the Azure App Service.  
**Managed Identity:** A system-assigned managed identity is enabled for the app, allowing it to securely access other Azure resources like the SQL Database and Container Registry.

### 4. Azure Application Insights
**Purpose:** Provides monitoring and diagnostics for the application.  
**Details:** The `azurerm_application_insights` resource tracks the application’s performance and any issues by integrating it into the app’s configuration.

### 5. Azure Container Registry
**Purpose:** Stores the Docker image used by the Azure App Service.  
**Details:** The `azurerm_container_registry` is a private registry where the Docker image of the application is stored. The app pulls this image from the registry during deployment.

### 6. Azure SQL Database
**Purpose:** Stores data for the application.  
**Details:** The `azurerm_mssql_server` and `azurerm_mssql_database` resources manage the SQL server and database used by the application. A private endpoint is set up for secure database access.

### 7. Azure Application Gateway
**Purpose:** Acts as a reverse proxy and load balancer for the application.  
**Details:** The `azurerm_application_gateway` is set up with SSL offloading and routing rules to forward traffic to the Azure App Service. It uses a static public IP for external access and HTTPS for secure connections.

### 8. Private Endpoints and DNS
**Purpose:** Ensure secure and private communication between resources.  
**Details:** The `azurerm_private_endpoint` provides secure communication with the SQL database using a private IP address, ensuring that traffic does not traverse the public internet. A private DNS zone is used to resolve the SQL server's private IP.

## Infrastructure Deployment via Azure DevOps
The infrastructure for this application is managed using Terraform and deployed automatically via a CI/CD pipeline in Azure DevOps. This pipeline ensures that all resources required for the application are provisioned and managed in a consistent and repeatable manner. 

## Python FastAPI Application

The Python FastAPI application provides a backend for managing employee and department data. It integrates with the Azure cloud infrastructure, utilizing Azure SQL Database for persistent storage and Azure networking components for secure communication. Below is a breakdown of the FastAPI components and their roles in the system:

### Key Components

1. **Employee Routes (employee.py)**

   - **Create Employee (`POST /employees/`)**: This endpoint allows the creation of new employees. The data is stored in the Azure SQL Database, and after insertion, employee information (such as name, job title, and department) is written to a CSV file for additional processing.
   
   - **Get Employee Details (`GET /employees/{employee_id}`)**: Fetches detailed information about an employee based on their ID from the SQL database.
   
   - **Update Employee Details (`PATCH /employees/{employee_id}`)**: Allows updating an employee's details, including first name, last name, position, manager status, and department.
   
   - **Delete Employee (`DELETE /employees/{employee_id}`)**: Deletes an employee record from the database.

2. **Department Routes (department.py)**

   - **Create Department (`POST /departments/`)**: This endpoint creates a new department and saves it in the database.
   
   - **Get Department Details (`GET /departments/{department_id}`)**: Retrieves detailed information about a department by its ID.
   
   - **Update Department Details (`PATCH /departments/{department_id}`)**: Allows the modification of department details, such as name or manager.
   
   - **Get All Departments (`GET /departments/`)**: Returns a list of all departments in the system.
   
   - **Get Employees in a Department (`GET /department/{department_id}/employees`)**: Lists all employees in a specific department.
   
   - **Delete Department (`DELETE /departments/{department_id}`)**: Deletes a department from the database, provided no employees are assigned to it.

### Models and Schemas

The system uses SQLAlchemy for ORM-based interaction with the Azure SQL Database. Models are defined for `Employee` and `Department` as follows:

- **Employee Model (`models.py`)**: Contains fields such as `first_name`, `last_name`, `job_title`, `hire_date`, `is_manager`, and `department_id`, along with relationships to the `Department` model.
  
- **Department Model (`models.py`)**: Contains fields for `name`, `manager_id`, and `created_at`, along with a relationship to the `Employee` model for managing the department's employees.

### Integration with Azure Infrastructure

- The application is hosted on Azure App Service within a Docker container, as described in the [Cloud Architecture](#cloud-architecture) section.
  
- The backend communicates with the Azure SQL Database through private endpoints, ensuring secure data access.

This system forms the backend for employee and department management, with secure and efficient integration into the Azure cloud infrastructure. It is designed for scalability and security, leveraging Azure's managed services like SQL Database, private networking, and App Service.

### Deployment and Containerization

- To containerize the FastAPI application, a Dockerfile is included, which defines the steps necessary to build and run the application within a Docker container. The Docker container allows the application to run consistently, regardless of where it is deployed.

- The application is deployed through an automated Azure DevOps pipeline, which builds and pushes the Docker image to an Azure Container Registry (ACR) and then deploys it to Azure App Service.

# Automation of User and Group Setup in Microsoft Entra ID

This project includes an automated process for setting up users in Microsoft Entra ID and associating them with specific groups based on their department. The process involves exporting employee data from an Azure SQL database, then using Terraform to create users and assign them to predefined groups in Microsoft Entra ID. The automation simplifies and accelerates the user provisioning process, ensuring consistency across the organization.

---

## Step 1: Export Employee Data from Azure SQL Database

Administrators can export employee data from the Azure SQL database into a CSV file using the following command:

```bash
sqlcmd \
  -S $SQL_SERVER \
  -U $SQL_USERNAME \
  -P $SQL_PASSWORD \
  -d $SQL_DATABASE \
  -Q "SELECT e.first_name, e.last_name, e.job_title, d.name AS department FROM dbo.employees e JOIN dbo.departments d ON e.department_id = d.id;" \
  -o "/Users/jaylonjones/Employee File System/users/users.csv" \
  -W \
  -s ","
This command queries the employee and department data from the employees table in the Azure SQL database, exporting the information (first name, last name, job title, and department) into a CSV file (users.csv).



  
