# Debug-code — Reference

## Diagnostic Strategy

1. **Minimize scanning.** Always ask the user for suspect files first. Never scan the full codebase unless all narrower strategies have failed.
2. **Stack trace first.** If provided, the stack trace is the most reliable lead. Work outward from the first project frame.
3. **Reproduce the path.** Trace the execution flow from user action → widget → provider/viewmodel → repository → data source.
4. **Expand progressively.** Read imports of suspect files before broadening to the full project. Each expansion level costs tokens — justify it.