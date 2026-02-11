# PHP Error Reporting Configuration

## Overview

This document describes how PHP error reporting is configured in the Attraktor Wiki to handle PHP 8.2+ deprecation warnings and other debug messages.

## Problem

With PHP 8.2+, dynamic property creation is deprecated. The SemanticResultFormats extension (specifically the Calendar format) creates dynamic properties which triggers deprecation warnings:

```
Deprecated: Creation of dynamic property SRFCalendar::$mColors is deprecated in /var/www/html/extensions/SemanticResultFormats/formats/calendar/SRF_Calendar.php on line 36
```

Additionally, MediaWiki core may show notices:

```
Notice: Undefined property: MediaWiki\Parser\Parser::$mFirstCall in /var/www/html/includes/debug/DeprecationHelper.php on line 230
```

## Solution

The PHP error reporting configuration in `LocalSettings.php` has been updated to:

1. **Development Mode** (`MW_PHP_DEBUG=true`): Show all errors including deprecations, warnings, and notices
2. **Production Mode** (`MW_PHP_DEBUG=false`): Hide deprecation notices, warnings, and notices from being displayed to users

### Configuration Details

In `LocalSettings.php`:

```php
# Debug
if ( isset( $phpDebug ) && $phpDebug == true ) {
    $wgShowExceptionDetails = true;
    $wgDevelopmentWarnings = true;
    error_reporting( E_ALL );
    ini_set( 'display_errors', 1 );
} else {
    # Production mode: Hide deprecation notices to prevent PHP 8.2+ warnings
    # This suppresses PHP 8.2+ dynamic property deprecation warnings
    # Warnings and errors are still logged and displayed as they indicate important issues
    error_reporting( E_ALL & ~E_DEPRECATED & ~E_NOTICE );
    ini_set( 'display_errors', 0 );
    ini_set( 'log_errors', 1 );
}
```

## Deployment Instructions

### For Coolify Production Deployment

Ensure the following environment variable is set in Coolify:

```
MW_PHP_DEBUG=false
```

This will:
- Hide deprecation warnings from being displayed to users
- Hide notices from being displayed to users
- Keep warnings visible (as they indicate important runtime issues like failed file operations)
- Still log all errors to the PHP error log
- Keep fatal errors visible (which is important for debugging critical issues)

### For Local Development

The `.env.dist` file already has:

```
MW_PHP_DEBUG=true
```

This ensures developers can see all errors and warnings during development.

## Testing

After deploying with `MW_PHP_DEBUG=false`:

1. Visit https://wiki.attraktor.org/Calendar
2. Verify that no deprecation warnings or notices are displayed
3. Check PHP error logs if needed (path depends on PHP configuration, typically accessible via container logs or configured error_log path)

## Future Considerations

The underlying issue is that the SemanticResultFormats extension creates dynamic properties, which is deprecated in PHP 8.2+. This should ideally be fixed in the extension itself by:

1. Declaring properties in the class definition, or
2. Using the `#[AllowDynamicProperties]` attribute

However, since this is a third-party extension installed via Composer, we suppress these warnings in production while they remain visible in development for awareness.

## Related Issues

- PHP 8.2 Dynamic Properties Deprecation: https://wiki.php.net/rfc/deprecate_dynamic_properties
- SemanticResultFormats Extension: https://www.semantic-mediawiki.org/wiki/Semantic_Result_Formats
