# Community Gardens and Urban Agriculture System

A comprehensive blockchain-based platform for managing community gardens, urban agriculture initiatives, and food security programs using Clarity smart contracts on the Stacks blockchain.

## Overview

This system provides a decentralized solution for community garden management, enabling transparent resource allocation, harvest tracking, knowledge sharing, and educational program coordination. Built with five interconnected Clarity smart contracts, it supports food security initiatives while fostering community engagement and sustainable urban agriculture practices.

## System Architecture

### Core Contracts

1. **Garden Management Contract** (`garden-management.clar`)
    - Plot allocation and management
    - Garden registration and administration
    - Member management and permissions
    - Plot assignment and transfer functionality

2. **Resource Sharing Contract** (`resource-sharing.clar`)
    - Tool and equipment sharing system
    - Resource availability tracking
    - Borrowing and lending mechanisms
    - Maintenance scheduling and notifications

3. **Harvest Distribution Contract** (`harvest-distribution.clar`)
    - Yield tracking and recording
    - Food distribution management
    - Surplus allocation to food banks
    - Harvest quality and safety monitoring

4. **Funding Management Contract** (`funding-management.clar`)
    - Transparent budget allocation
    - Expense tracking and reporting
    - Community funding proposals
    - Grant and donation management

5. **Education Hub Contract** (`education-hub.clar`)
    - Knowledge sharing platform
    - Educational program coordination
    - Workshop scheduling and attendance
    - Resource library management

## Key Features

### Plot Management
- **Dynamic Plot Allocation**: Automated assignment based on availability and member preferences
- **Plot Transfer System**: Secure transfer of plot ownership between community members
- **Usage Tracking**: Monitor plot activity and productivity metrics
- **Waiting List Management**: Fair queue system for plot assignment

### Resource Sharing
- **Equipment Library**: Comprehensive tool and equipment sharing system
- **Availability Calendar**: Real-time tracking of resource availability
- **Maintenance Scheduling**: Automated maintenance reminders and scheduling
- **Usage Analytics**: Track resource utilization and maintenance needs

### Harvest & Distribution
- **Yield Recording**: Detailed harvest tracking with quantity and quality metrics
- **Distribution Planning**: Automated distribution based on community needs
- **Food Security Support**: Priority allocation for food-insecure community members
- **Surplus Management**: Efficient distribution of excess produce to local food banks

### Financial Transparency
- **Budget Tracking**: Real-time monitoring of garden expenses and income
- **Proposal System**: Community-driven funding proposals and voting
- **Grant Management**: Streamlined application and tracking of external funding
- **Expense Reporting**: Detailed financial reporting and audit trails

### Educational Programs
- **Workshop Management**: Scheduling and coordination of educational workshops
- **Knowledge Base**: Comprehensive library of gardening resources and best practices
- **Mentorship Program**: Connect experienced gardeners with newcomers
- **Progress Tracking**: Monitor learning outcomes and program effectiveness

## Technical Specifications

### Data Types
- **Garden**: Comprehensive garden information including location, size, and management details
- **Plot**: Individual plot data with ownership, status, and productivity metrics
- **Resource**: Equipment and tool specifications with availability and condition status
- **Harvest**: Detailed harvest records with yield data and quality assessments
- **Member**: Community member profiles with permissions and activity history

### Security Features
- **Role-Based Access Control**: Hierarchical permission system for different user types
- **Multi-Signature Operations**: Critical operations require multiple approvals
- **Audit Trail**: Comprehensive logging of all system activities
- **Data Validation**: Strict input validation and error handling

## Installation & Setup

### Prerequisites
- Clarinet CLI installed
- Node.js 18+ for testing
- Stacks wallet for deployment

### Local Development
\`\`\`bash
# Clone the repository
git clone <repository-url>
cd community-gardens

# Install dependencies
npm install

# Run tests
npm test

# Deploy to local testnet
clarinet integrate
\`\`\`

### Contract Deployment
\`\`\`bash
# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
\`\`\`

## Usage Examples

### Register a New Garden
```clarity
(contract-call? .garden-management register-garden 
  "Community Garden North" 
  "123 Main St" 
  u50 
  u10)
