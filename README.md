# Quick-Book-Integration-with-Salesforce

This repository contains a solution for integrating Salesforce and QuickBooks. The solution is designed to automatically create a customer in QuickBooks whenever an Opportunity is closed won in Salesforce

## Prerequisites
Before using this solution, you need to have the following:

A Salesforce account with access to the Opportunity object
A QuickBooks account with the API access enabled.

## Installation

1.Connect quickbook with salesforce by creating "Auth. Provider" and "Connected app" in salesforce for this you will require the access token of quickbook API(create quickbook Account).

2.Create a new Apex class in Salesforce and copy the contents of the createCustomerWebservice.cls file in the repository to the class and edit the endpoint url.

3.reate a new Apex trigger in Salesforce and copy the contents of the OpportunityTrigger.trigger file in the repository to the trigger.

## Usage
Once you've completed the installation steps, the integration will automatically create a customer in QuickBooks whenever an Opportunity's stage is updated to "Closed Won" in Salesforce. The customer will be created with the Opportunity name in QuickBooks.

