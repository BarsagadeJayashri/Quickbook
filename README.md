# Quick-Book-Integration-with-Salesforce

This repository contains a solution for integrating Salesforce and QuickBooks. The solution is designed to automatically create a customer in QuickBooks whenever an Opportunity is closed won in Salesforce

## Prerequisites
Before using this solution, you need to have the following:

A Salesforce account with access to the Opportunity object
A QuickBooks account with the API access enabled.

## Installation

1.Connect quickbook with salesforce by creating "Auth. Provider" and "Connected app" in salesforce for this you will require the access token of quickbook API(create quickbook Account).

2.Create the custom object Name "Quickbook Event Notification" as provided in 'Custom Object' Folder.

3.Create Apex classes and trigger as provided.

## Usage
Once you've completed the installation steps, the integration will automatically create the following.
1. Customer in Quickbook whenever the Account is created in salesforce.
2. Invoice in QuickBooks whenever an Opportunity's stage is updated to "Closed Won" in Salesforce. 
3. whenever the customer is updated in Quickbook then The related Account in Salesforce will also get Updated.
4. whenever the customer is created in Quickbook then The Account will be created in Salesforce .
