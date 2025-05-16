# Test-Azure-architecture-diagram

# System Architecture Overview (C4 Model)

## 1. Context Diagram

**Purpose**: Shows how the system fits into the world.

**Description**:  
Our system is a web-based ticketing platform used by customers to purchase event tickets. It interacts with external services like payment gateways and email notifications.

### Participants:
- **User**: Uses the web application
- **Ticketing System**: Main system under discussion
- **Payment Gateway**: External service for payments
- **Email Service**: External service for notifications

```plantuml
@startuml
!includeurl https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

Person(user, "Customer", "Purchases tickets")
System(ticketSystem, "Ticketing Platform", "Handles ticket purchases")
System_Ext(payment, "Payment Gateway", "Processes payments")
System_Ext(email, "Email Service", "Sends notifications")

Rel(user, ticketSystem, "Uses")
Rel(ticketSystem, payment, "Uses")
Rel(ticketSystem, email, "Sends email to")

@enduml





