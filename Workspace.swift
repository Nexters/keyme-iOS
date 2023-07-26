import ProjectDescription

import EnvPlugin

let workspace = Workspace(
    name: Environment.appName,
    projects: [
        "Projects/**"
    ]
)
