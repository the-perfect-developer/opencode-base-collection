# Requirement Questions Catalog

Comprehensive question sets for different feature types to gather complete requirements.

## General Questions (Ask for All Features)

These questions apply to every feature regardless of type:

### Core Understanding
1. **What problem does this feature solve?**
   - Who experiences this problem?
   - How do they currently work around it?
   - What is the impact of not having this feature?

2. **What is the desired outcome?**
   - What should users be able to do after implementation?
   - What specific behavior should change?
   - How will success be measured?

3. **Who are the stakeholders?**
   - Who requested this feature?
   - Who will use this feature?
   - Who needs to be consulted during implementation?

4. **What are the constraints?**
   - Timeline or deadline requirements?
   - Budget or resource constraints?
   - Technology restrictions or requirements?

### Technical Context
5. **Are there existing systems to integrate with?**
   - Internal APIs or services?
   - Third-party integrations?
   - Database dependencies?

6. **Are there specific technical requirements?**
   - Performance requirements (latency, throughput)?
   - Scalability requirements (concurrent users, data volume)?
   - Security requirements (compliance, data sensitivity)?

7. **What is the expected usage?**
   - How many users will use this feature?
   - How frequently will it be used?
   - What are peak usage times?

## Feature-Specific Questions

### Authentication Features

1. **Authentication Method**
   - What authentication method? (OAuth, SAML, email/password, multi-factor)
   - Which providers? (Google, GitHub, Microsoft, etc.)
   - Is social login required?

2. **User Management**
   - How should users be created? (self-registration, admin-created, invited)
   - What user data is required? (email, username, profile info)
   - How should passwords be managed? (strength requirements, reset flow)

3. **Session Management**
   - How long should sessions last?
   - Should users stay logged in? (remember me functionality)
   - How should sessions be invalidated?

4. **Security Requirements**
   - What security standards must be met? (OWASP, SOC2, HIPAA)
   - Is multi-factor authentication required?
   - Are there password complexity requirements?

5. **Migration Concerns**
   - Are there existing users to migrate?
   - How should existing users transition?
   - Can old authentication methods remain active?

### API Features

1. **API Design**
   - What type of API? (REST, GraphQL, gRPC)
   - What resources need to be exposed?
   - What operations are needed? (CRUD, custom actions)

2. **Data Format**
   - What data format? (JSON, XML, Protocol Buffers)
   - What is the request/response structure?
   - Are there schema validation requirements?

3. **Authentication & Authorization**
   - How will API consumers authenticate? (API keys, OAuth, JWT)
   - What authorization model? (RBAC, ABAC, resource-based)
   - What rate limiting is required?

4. **Versioning**
   - How should API be versioned? (URL, header, content negotiation)
   - What is the deprecation policy?
   - How will breaking changes be communicated?

5. **Documentation**
   - What documentation format? (OpenAPI/Swagger, GraphQL schema, custom)
   - Should there be interactive documentation?
   - Are code examples needed for different languages?

### Database Features

1. **Data Model**
   - What entities/tables are needed?
   - What are the relationships between entities?
   - What are the data types and constraints?

2. **Data Volume**
   - How much data is expected? (initial, 1 year, 5 years)
   - What is the growth rate?
   - Are there archival requirements?

3. **Query Patterns**
   - What are the most common queries?
   - Are there complex aggregations needed?
   - What are the performance requirements for queries?

4. **Data Migration**
   - Is there existing data to migrate?
   - What is the migration strategy? (all at once, gradual, dual-write)
   - What is the rollback plan if migration fails?

5. **Backup & Recovery**
   - What are the backup requirements? (frequency, retention)
   - What is the acceptable data loss? (RPO)
   - What is the acceptable downtime? (RTO)

### UI Features

1. **User Experience**
   - What user flows are involved?
   - What is the expected user journey?
   - Are there wireframes or mockups?

2. **Visual Design**
   - Are there design specifications? (colors, typography, spacing)
   - Should existing design system be used?
   - Are there accessibility requirements? (WCAG level)

3. **Responsive Design**
   - Which devices should be supported? (mobile, tablet, desktop)
   - What are the minimum supported screen sizes?
   - Are there mobile-specific features needed?

4. **Interactivity**
   - What interactions are required? (clicks, drags, gestures)
   - Are there animations or transitions?
   - What is the expected response time for user actions?

5. **Offline Support**
   - Should feature work offline?
   - How should conflicts be resolved when reconnecting?
   - What data should be cached locally?

### Data Export/Import Features

1. **Data Format**
   - What formats should be supported? (CSV, JSON, XML, Excel, PDF)
   - Are there specific format requirements? (column order, encoding)
   - Should format be configurable?

2. **Data Selection**
   - Can users select which data to export?
   - Are there filters or date ranges?
   - Can users select which fields to include?

3. **Data Volume**
   - What is the maximum expected export size?
   - Should large exports be asynchronous? (email link when ready)
   - Are there pagination requirements?

4. **Data Import**
   - How should import errors be handled? (reject all, partial import, report errors)
   - Is data validation required before import?
   - Should duplicate detection be implemented?

5. **Security**
   - Should exports be encrypted?
   - Who can export data? (authorization requirements)
   - Should exports be audited/logged?

### Integration Features

1. **Integration Type**
   - What type of integration? (webhook, polling, real-time sync)
   - Which direction? (inbound, outbound, bidirectional)
   - What is the integration frequency?

2. **Third-Party System**
   - Which system to integrate with?
   - What is the API documentation?
   - What are the rate limits?

3. **Data Mapping**
   - How should data be mapped between systems?
   - Are there transformations needed?
   - How should conflicts be resolved?

4. **Error Handling**
   - How should failures be handled? (retry, alert, queue)
   - What is the retry strategy?
   - How should partial failures be handled?

5. **Monitoring**
   - What metrics should be tracked?
   - How should failures be alerted?
   - Is there a status dashboard needed?

### Performance Optimization Features

1. **Current Performance**
   - What are the current performance metrics?
   - Where are the bottlenecks?
   - What is the desired performance improvement?

2. **Optimization Targets**
   - What should be optimized? (latency, throughput, resource usage)
   - What are the acceptable trade-offs? (consistency vs speed, cost vs performance)
   - Are there specific operations to focus on?

3. **Caching Strategy**
   - What should be cached?
   - What is the cache invalidation strategy?
   - Where should cache be stored? (memory, Redis, CDN)

4. **Resource Constraints**
   - What are the resource limits? (CPU, memory, network)
   - Are there cost constraints?
   - What is the scalability target? (concurrent users, data volume)

5. **Monitoring**
   - What performance metrics should be tracked?
   - What are the alerting thresholds?
   - How should performance be tested?

## Question Flow Strategy

### Start Broad, Then Narrow

1. **High-level understanding** (2-3 questions)
   - What is the feature?
   - Why is it needed?
   - Who will use it?

2. **Technical requirements** (3-5 questions)
   - What are the technical constraints?
   - What systems are involved?
   - What performance is expected?

3. **Detailed specifications** (5-10 questions)
   - Use feature-specific questions above
   - Ask follow-up questions based on answers
   - Clarify ambiguities

### Adaptive Questioning

Based on initial answers, ask follow-up questions:

**If user mentions "third-party integration"**:
- Which specific service?
- Do you have API credentials?
- What data needs to be synced?

**If user mentions "high performance requirements"**:
- What is the expected load?
- What is the acceptable latency?
- Are there specific bottlenecks?

**If user mentions "security concerns"**:
- What compliance requirements exist?
- What data classification level?
- Are there specific security standards?

## Question Templates

Use these templates to formulate clear questions:

### Understanding Template
```
To make sure I understand correctly, you want to [paraphrase feature].
Is that accurate? Are there any aspects I'm missing?
```

### Clarification Template
```
You mentioned [specific detail]. Could you clarify:
- [Specific question 1]
- [Specific question 2]
```

### Option Template
```
For [aspect of feature], there are several approaches:
1. [Option 1] - [Brief description]
2. [Option 2] - [Brief description]
3. [Option 3] - [Brief description]

Which approach fits your needs best, or do you have a different preference?
```

### Constraint Template
```
Are there any constraints I should be aware of regarding:
- Timeline: [when does this need to be completed?]
- Resources: [budget, team size, technology stack?]
- Compatibility: [existing systems, browsers, devices?]
```

## Example Question Flow

### Example: User requests "Add OAuth authentication"

**Phase 1: High-Level Understanding**
```
Q1: What prompted the need for OAuth authentication?
A: We want users to sign in with Google/GitHub instead of managing passwords.

Q2: Should email/password authentication remain available?
A: Yes, as an alternative option.

Q3: Who will use OAuth? All users or specific user types?
A: All users, but especially new users signing up.
```

**Phase 2: Technical Requirements**
```
Q4: Which OAuth providers should be supported initially?
A: Google and GitHub to start.

Q5: Are there plans to add more providers later?
A: Possibly Microsoft and Apple in the future.

Q6: Are there existing users who need to migrate?
A: Yes, about 5,000 existing users with email/password.
```

**Phase 3: Detailed Specifications**
```
Q7: How should existing users link their OAuth accounts?
A: They should be able to link OAuth to existing accounts when logged in.

Q8: What user data do you need from OAuth providers?
A: Email, name, and profile picture at minimum.

Q9: How long should OAuth sessions last?
A: Same as current sessions - 24 hours, with refresh tokens for longer sessions.

Q10: Are there any compliance requirements (GDPR, CCPA, etc.)?
A: Yes, GDPR - we need to allow users to disconnect OAuth accounts and delete data.
```

**Result**: Complete picture of OAuth feature requirements for planning.

## Summary

**General Questions**: Always ask (7 core questions)

**Feature-Specific Questions**: Choose relevant set based on feature type
- Authentication: 5 question areas
- API: 5 question areas
- Database: 5 question areas
- UI: 5 question areas
- Export/Import: 5 question areas
- Integration: 5 question areas
- Performance: 5 question areas

**Question Flow**: Start broad → narrow to technical → detail specific

**Adaptive Questioning**: Follow up based on answers, ask clarifying questions

Use these question catalogs to ensure complete requirement gathering before planning implementation.
