# Resource Loading Failures

The HUD and EventManager verify that resources loaded at runtime are valid before use. When a resource fails to load or has the wrong type, a warning is logged and the resource is skipped.

## Failure Cases

- **Missing resource files**: If an expected `.tres` file cannot be found, a warning such as `Failed to load event resource: res://resources/events/Foo.tres` is printed.
- **Incorrect resource type**: When a resource loads but does not inherit from the expected base class (`GameEventBase`, `PolicyBase`, or `Building`), it is ignored and a warning explains the mismatch.

These warnings appear in the Godot output and help track down misconfigured or missing content without interrupting gameplay.
