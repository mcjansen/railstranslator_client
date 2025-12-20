# RailstranslatorClient

A Rails Engine that syncs translations from a RailsTranslator server to your Rails application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "railstranslator_client", path: "/path/to/railstranslator_client"
# Or from git:
# gem "railstranslator_client", git: "https://github.com/example/railstranslator_client"
```

Then execute:

```bash
bundle install
```

## Configuration

Create an initializer `config/initializers/railstranslator.rb`:

```ruby
RailstranslatorClient.configure do |config|
  # Required settings
  config.api_url = ENV["RAILSTRANSLATOR_URL"]       # e.g., "https://translator.example.com"
  config.api_key = ENV["RAILSTRANSLATOR_API_KEY"]   # Your app's export API key
  config.app_slug = ENV["RAILSTRANSLATOR_APP_SLUG"] # Your app's slug in RailsTranslator

  # Optional settings
  config.locales_path = Rails.root.join("config/locales/synced")  # Default: config/locales
  config.locales = [:nl, :en, :fr, :de]                            # Default: all available
  config.webhook_secret = ENV["RAILSTRANSLATOR_WEBHOOK_SECRET"]    # Protect sync endpoint
end
```

## Usage

### Mount the Engine

In your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount RailstranslatorClient::Engine => "/railstranslator"
end
```

This provides:
- `POST /railstranslator/sync` - Trigger a sync (can be called by webhook)
- `GET /railstranslator/status` - Check configuration status

### Sync via Rake Task

```bash
# Sync all locales
rake translations:sync

# Sync specific locale
LOCALE=nl rake translations:sync

# Check configuration
rake translations:status
```

### Sync Programmatically

```ruby
# Sync all configured locales
RailstranslatorClient.sync!

# Sync specific locale
RailstranslatorClient.sync!(locale: :nl)
```

### Webhook Integration

Configure RailsTranslator to call your sync endpoint when translations are updated:

1. Set a webhook secret in both applications
2. Configure the webhook URL in RailsTranslator: `https://your-app.com/railstranslator/sync`
3. RailsTranslator will POST to this endpoint with `X-Webhook-Secret` header

## How It Works

1. The client fetches translations from the RailsTranslator API
2. Translations are written to YAML files in your `config/locales` directory
3. Rails automatically reloads I18n translations on the next request

## File Structure

After syncing, your locale files will look like:

```
config/locales/
├── nl.yml      # Synced from RailsTranslator
├── en.yml      # Synced from RailsTranslator
├── fr.yml      # Synced from RailsTranslator
└── defaults.yml # Your existing local translations
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `RAILSTRANSLATOR_URL` | Base URL of RailsTranslator server |
| `RAILSTRANSLATOR_API_KEY` | Export API key from RailsTranslator |
| `RAILSTRANSLATOR_APP_SLUG` | Your application's slug |
| `RAILSTRANSLATOR_WEBHOOK_SECRET` | Optional secret for webhook authentication |

## License

MIT License
