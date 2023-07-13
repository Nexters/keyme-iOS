import ProjectDescription
import ProjectDescriptionHelpers
import Environment

/*
                +-------------+
                |             |
                |     App     | Contains Keyme App target and Keyme unit-test target
                |             |
         +------+-------------+-------+
         |         depends on         |
         |                            |
 +----v-----+                   +-----v-----+
 |          |                   |           |
 |   Kit    |                   |     UI    |   Two independent frameworks to share code and start modularising your app
 |          |                   |           |
 +----------+                   +-----------+

 */

// MARK: - Project
// Creates our project using a helper function defined in ProjectDescriptionHelpers
let project = Project.app(name: "Keyme",
                          platform: .iOS,
                          additionalTargets: ["KeymeKit", "KeymeUI"])
