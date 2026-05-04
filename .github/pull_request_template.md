## Problem

<!-- What problem does this PR solve? Why is this change needed? -->
<!-- Example: "Generating a controller for nested resources (v1/admin/users) produces wrong namespace, causing autoload errors" -->
<!-- Example: "Host app has no way to validate input before reaching Operation, forcing manual validation in every Operation" -->



## Solution

<!-- Describe the approach, not file listings. Focus on HOW the problem above is solved. -->
<!-- Example: "Extract namespace resolution logic into a dedicated helper, handling recursion for multi-level namespaces" -->
<!-- Example: "Add Form generator that auto-creates form classes with attribute definitions from CLI arguments" -->



## Impact

<!-- Who and what does this change affect? -->

- **Generator output:** <!-- Any changes to generated files or structure? -->
- **Host app:** <!-- Are existing apps affected? Do they need to re-run init? -->
- **Breaking change:** Yes / No <!-- If yes, describe migration path -->

## Verification

<!-- How was this verified? -->

- [ ] RSpec: `bundle exec rspec`
- [ ] Manual test on example app (see `docs/en/testing.md`)
- [ ] Generated files follow HMVC structure

<!--
If manually tested, record the command and result:
```
rails g hmvc:controller v1/users --type=api
# => Creates controller, 5 operations, 2 forms
```
-->

## Additional Context

<!-- Anything else the reviewer should know? Trade-offs, limitations, or next steps? -->
<!-- Remove this section if not needed -->
