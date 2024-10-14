# Transactions API of BanKonG - Documentation

## Overview

**Version:** 1.1.0  
**Description:** This API provides access to the transactions of a logged-in user. You can perform actions such as retrieving, creating, updating, and deleting transactions, depending on the user's permissions.

- 🔐 This API is protected by either OpenID Connect or an API key.
- 💡 The API is rate-limited.

**Contact:**

- **Name:** BanKonG PointOfContact
- **Website:** [BanKonG Support](http://www.bankong.com/support)
- **Email:** [support@bankong.com](mailto:support@bankong.com)

---

## Servers

### Local Sandbox Environment
- **URL:** `http://transactions.bankong.local`
- **Internal:** Yes

### Gateway in K8s
- **URL:** `http://api.transactions.k8s.orb.local`
- **Internal:** No

---

## Security

This API requires one of the following security schemes:
1. **API Key Authentication:** Pass the `apikey` in the header.
2. **OIDC (OpenID Connect):** Use a bearer token in JWT format.

---

## Endpoints

### 1. List All Transactions

**Endpoint:** `GET /transactions`  
**Summary:** Retrieve a list of all transactions.  
**Operation ID:** `listTranactions`  
**Tags:** Transactions  

**Responses:**
- **200 OK:** A list of transactions will be returned.
  - **Content:** `application/json`
  - **Schema:** [TransactionsList](#transactionslist)

---

### 2. Create New Transaction

**Endpoint:** `POST /transactions`  
**Summary:** Create a new transaction.  
**Operation ID:** `initiateTransaction`  
**Tags:** Transactions  

**Request Body:**
- **Content Type:** `application/json; charset=utf-8`
- **Schema:** [Transaction](#transaction)

**Responses:**
- **200 OK:** The newly created transaction is returned.
  - **Content:** `application/json`
  - **Schema:** [Transaction](#transaction)

---

### 3. Get Specific Transaction

**Endpoint:** `GET /transactions/{id}`  
**Summary:** Retrieve details of a specific transaction by ID.  
**Operation ID:** `getTransaction`  
**Tags:** Transactions  

**Parameters:**
- **id (Path Parameter):**  
  - **Description:** The transaction ID.  
  - **Required:** Yes  
  - **Schema:** [TransactionId](#transactionid)

**Responses:**
- **200 OK:** The requested transaction is returned.
  - **Content:** `application/json`
  - **Schema:** [Transaction](#transaction)
- **404 Not Found:** The transaction with the given ID does not exist.

---

### 4. Update a Transaction

**Endpoint:** `PATCH /transactions/{id}`  
**Summary:** Update an existing transaction.  
**Operation ID:** `changeTransaction`  
**Tags:** Transactions  

**Parameters:**
- **id (Path Parameter):**  
  - **Description:** The transaction ID.  
  - **Required:** Yes  
  - **Schema:** [TransactionId](#transactionid)

**Request Body:**
- **Content Type:** `application/json; charset=utf-8`
- **Schema:** [Transaction](#transaction)

**Responses:**
- **200 OK:** The updated transaction is returned.
  - **Content:** `application/json`
  - **Schema:** [Transaction](#transaction)
- **404 Not Found:** The transaction with the given ID does not exist.

---

### 5. Cancel a Transaction

**Endpoint:** `DELETE /transactions/{id}`  
**Summary:** Cancel an existing transaction.  
**Operation ID:** `cancelTransaction`  
**Tags:** Transactions  

**Parameters:**
- **id (Path Parameter):**  
  - **Description:** The transaction ID.  
  - **Required:** Yes  
  - **Schema:** [TransactionId](#transactionid)

**Responses:**
- **200 OK:** The cancelled transaction is returned.
  - **Content:** `application/json`
  - **Schema:** [Transaction](#transaction)
- **404 Not Found:** The transaction with the given ID does not exist.

---

## Components

### Schemas

#### 1. TransactionId

- **Type:** Integer  
- **Description:** A unique and immutable identifier for the transaction.  
- **Example:** `42`

#### 2. TransactionsList

- **Type:** Array  
- **Items:** [Transaction](#transaction)

#### 3. Transaction

- **Type:** Object  
- **Required Properties:**
  - `id` 
  - `source`
  - `senderName`
  - `destination`
  - `amount`
  - `currency`
  - `subject`

- **Properties:**
  - **id:**  
    - **Type:** Integer  
    - **Description:** The unique identifier of the transaction.  
    - **Example:** `42`
  - **source:**  
    - **Type:** String  
    - **Description:** The IBAN of the sending account.  
    - **Pattern:** `^[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[0-9]{7}([a-zA-Z0-9]?){0,16}$`  
    - **Example:** `GR872659435350353`
  - **senderName:**  
    - **Type:** String  
    - **Example:** `Max Mustermann`
  - **destination:**  
    - **Type:** String  
    - **Description:** The IBAN of the receiving account.  
    - **Pattern:** `^[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[0-9]{7}([a-zA-Z0-9]?){0,16}$`  
    - **Example:** `DE8412325587359375895`
  - **amount:**  
    - **Type:** Number  
    - **Description:** The amount of the transaction. Cannot be negative.  
    - **Minimum:** `0.01`  
    - **Multiple Of:** `0.01`  
    - **Example:** `42.00`
  - **currency:**  
    - **Type:** String  
    - **Description:** A currency code (ISO 4217 standard).  
    - **Pattern:** `^[A-Z]{3,3}$`  
    - **Example:** `EUR`
  - **subject:**  
    - **Type:** String  
    - **Description:** Description for the statement fee.  
    - **Min Length:** `0`  
    - **Max Length:** `128`  
    - **Example:** `Invoice #42-08/15`

---

## Security Schemes

### 1. ApiKeyAuth

- **Type:** `apiKey`
- **In:** `header`
- **Name:** `apikey`

### 2. OIDC

- **Type:** `http`
- **Scheme:** `bearer`
- **Bearer Format:** `JWT`

--- 

## Tags

### Transactions

- **Description:** Everything about transactions.  
- **External Documentation:** [Transaction Docs](http://docs.bankong.com/transations)
