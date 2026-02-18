# Transaction Content Format

### Standard Format
```
CLAUDEKIT {order-uuid}
```
Example: `CLAUDEKIT 4e4635f4-0478-4080-a5c5-48da91f97f1e`

### Team Checkout Format
```
TEAM{8-hex-chars}
```
Example: `TEAM4E4635F4`

### Why These Formats
- UUID ensures global uniqueness
- `CLAUDEKIT` prefix for easy visual identification
- Short team prefix fits bank memo limits
- Case-insensitive matching handles bank transformations
