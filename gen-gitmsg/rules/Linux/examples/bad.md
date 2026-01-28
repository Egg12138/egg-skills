# Bad Commit Message Examples for Linux Rule

## ❌ Example 1: Wrong Mood
```
driver: Fixed the NULL pointer issue

❌ Should use imperative: "driver: fix NULL pointer issue"
```

## ❌ Example 2: Period in Subject
```
mm: add THP support.

❌ Remove period: "mm: add THP support"
```

## ❌ Example 3: Subject Too Long
```
driver: implement comprehensive error handling for all edge cases in the probe function

❌ Subject exceeds 70 characters. Rephrase or move details to body.
```

## ❌ Example 4: Missing Component
```
This adds a new driver for XYZ hardware.

❌ Missing component prefix. Should be: "driver: add support for XYZ hardware"
```

## ❌ Example 5: Explains "How" Instead of "What/Why"
```
driver: improve initialization

Changed the init function to allocate memory with kzalloc()
instead of kmalloc() to avoid uninitialized data, added
a check for NULL return value, and updated the error path
to free the allocated structure.

❌ Body focuses on implementation details. Better to explain
   what problem was solved and why the change matters.
```

## ❌ Example 6: Capitalized Component
```
Driver: add support for new device

❌ Component should be lowercase: "driver: add support for new device"
```

## ❌ Example 7: No Blank Line After Subject
```
driver: fix memory leak
The driver was not freeing resources on error path.

❌ Missing blank line between subject and body.
```
