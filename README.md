# Customer Success Balancing
* Disclaimer: This document was written in English for practicity in order to maintain source code and documents in same language. For further use by the team, it could (or should) be translated to the best convenience to everyone.

---

## Project Short Description

The project consists of the management relationship with **Customers** (Our clients) and **Customer Success Managers** (Our Strategy managers for our customers). Depending of the size of our **customer** (the client's company size), we must organize the best effort adding most experienced **Customer Success Managers** to attend that **Customer**.

The **Customer Success Manager** could attend more than one **customer** and sometimes, the **Customer Success Manager**, could be unavailable. We is important to consider that context for balancing **customers** for **Customer Success Managers**.

The rule for balancing is deal out **Customer Success Managers** capacity's similar(higher) score with the **customers** size score, and group them together in a partition.


## Programming Language

I've chosen use of **Ruby** for this Challenge. This decision was choosen by past experiences:

**Ruby**: I worked on Ruby (particulary **RoR**) for the past 3 years and have been the more confortable language for me.

### Ruby Version
 ```ruby 3.1.1p18 (2022-02-18 revision 53f5fc4236)```

**Tools**: I use rbenv as ruby version management. I choosed that tool in order to avoid some annoying **RVM** warnings in my environment.
### Tools
 ```rbenv 1.2.0```
 ```minitest-5.15.0```

## Design and Architecture
In order to maintain some good code quality practices, designs and architectures, developers follow as good references **Clean Code and Clean Architecture Books** written by Robert Martin (Uncle Bob).

Other good principles good to follow are **DRY** and **Domain Knowledge** presented by Andy Hunt and Dave Thomas in the **pragmatic programmer book**. Additional to that, we also have the **DAMP** definitions by Jay Fields which can be found [at this book](https://leanpub.com/wewut).

The Challenge presented a unique file **customer_success_balancing.rb** that contains a class for the Application and a class for the Application Test and I didn't change that structure.

But, as good practices to evolve could be spliting the code one for the app running class file and other for running test file.

Maybe could be a good suggestion the following strucuture:

```
- app
  - lib
    customer_success_balacing.rb
  - test
    test_helper.rb (for some requires and setup)
    customer_success_balacing_test.rb (in better structure using describe, it and best modularization)
```

It can be noticed that in the raw CustomerSuccessBalacing class test example (before the implementation of execute), that follows good practice for single responsability. That remembers ServiceObject Pattern that we give parameters and a unique .execute call and get the information that we want.

For my implementation, some good practices that could be extended for scaling the application: 
   - **group_customers_in_customer_success_partitions method** could be extended to a new class service and be reusable somewhere. That returns a structure of customers in customerSuccess partitions.
   - **select_the_best_customer_success method** could be optimized also in other class and also be reusable. That could made an abstraction to receive any kind of structure to be found the best partition for the Customer Success Managers.

## Tests
  I've left the tests name as the example and added some extra ones:
  - They ranges from **test_scenario_one** through **test_scenario_fifteen**

  As better approach would be use spec files in a **descrptive** approach using `describe`, `context ` and `it` modularization.

## Instaling and Running the Test Locally
  - install minitest gem as follow:
  ``` 
   >> gem install minitest 
  ```

  - Run it: 
  ```
  >> cd customer-success
  >> ruby customer_success_balancing.rb
  ```


