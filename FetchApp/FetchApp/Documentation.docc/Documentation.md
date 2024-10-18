# ``FetchApp``

## Steps to Run the App
- Open the `FetchApp.xcworkspace` file and build the `FetchApp` target on simulator or device
- Pull from the top of the list to refresh recipe.

---
## Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
- Clean Architecutre
    - I believe that building a clean architecture is the most crucial aspect of a codebase project. It demonstrates a developer’s ability to break down requirements into smaller subproblems and design an architecture that is **maintainable, testable, and adaptable to future changes**. 
    - By **isolating the business logic from frameworks and the UI**, I ensured that each component could be updated or replaced without affecting others. I also applied **single responsbility** and **dependency inversion** principle heavily, ensuring that the system maintain high cohesion and low coupling between components. A great architecture not only enhances flexibility but also saves the company money and time in the long run by reducing technical debt and making future development faster and more efficient
- TDD (Test-Driven-Development)
    - Adopting TDD allowed me to ensure that the codebase was reliable and maintainable. Witing tests first helped clarify the behavior of the application before implmentation, improving overall stability of the system.
    - I wrote tests for the entire `Fetch` framework, achieving **98% code coverage**. Ensuring that all components of the framework work exactly as intended gives me confidence in the stability of the codebase and significantly reduces debugging time. I also tested key patterns like the `Decorator` and `Composite` design patterns that were implemented in the business logic, ensuring that their operations meet the project requirements.
    
---
## Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?
I spent roughly over six hours on this project. The majority of my time was focused on designing a clean architecture and writing comprehensive tests. While some might argue that implementing TDD takes longer, and I did spend more time than the average 4-5 hours, I believe the additional time spent on writing tests will pay off in the long run by significantly reducing debugging time and making it easier to extend the architecture. This upfront investment in testing ensures that the system is stable and adaptable to future changes, ultimately saving time during future development.

---
## Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
- I designed the ``RecipeImageDataLoader`` with a ``cancel`` method to give the client the flexibility to cancel unfinished tasks. This decision allowed for better control over resource-intensive operations, such as loading large images, especially in cases where a task might no longer be relevant (e.g., when scrolling). However, this design decision later made it challenging for me to leverage the ``Combine`` framework to create a universal abstraction. ``Combine`` handles task management in a more reactive way, and combining the manual cancellation logic with Combine’s declarative approach introduced complexity.

- A possible alternative could have been to design a more Combine-friendly API from the start, but I decided the cancel functionality was more critical for the current architecture and immediate needs of the app. The trade-off allowed me to retain fine-grained control at the cost of future flexibility.

```swift
public protocol RecipeImageDataLoaderTask {
    func cancel()
}

public protocol RecipeImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> RecipeImageDataLoaderTask
}
```
---
## Weakest Part of the Project: What do you think is the weakest part of your project?
- The UI & UX still left a lot to be desired. I really enjoy building UI and try new elements to creat better UX. Unfortunately, I've spent too much time on test-driving my project, which left me no chocie but to simplify my UI presentation.

---
## External Code and Dependencies: Did you use any external code, libraries, or dependencies?
-  I chose not to use any external libraries or dependencies for this project. While external libraries can often speed up development, I believe they can become a liability in the long run, especially when it comes to maintaining and testing the codebase. By relying on native frameworks and writing my own implementations, I ensure that the project remains fully under my control, making it easier to update and adapt without worrying about third-party library compatibility or deprecation.

---
## Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
- Due to the limitation of the minimum supported iOS version, I couldn’t take advantage of some of Apple’s newer technologies, such as ``SwiftData``, ``Observation``, and certain SwiftUI framework modifiers. In my experience, I find ``CoreData`` cumbersome to set up, with a lot of reliance on ``Objective-C``, which can complicate the implementation. While ``SwiftData`` is still relatively new and I encountered several bugs when abstracting it away from ``SwiftUI``, it offers a more readable and easier setup. I believe ``SwiftData`` holds great potential for simplifying data management in future projects.
