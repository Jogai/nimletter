# 💌 Nimletter

**Self-hosted newsletter, drip, and transactional email system**.

Nimletter is built to replace the simple functionalities found in Mailchimp, Mailerlite, Sendgrid, and others. Let users subscribe and automatically start flows, or just send out your weekly newsletter.

![Nimletter Logo](assets/images/nimletter.png)

## ✨ Features

- 🚀 **BYOD SMTP server**
- 🖱️ **Drag and Drop email builder**
- 📝 **Variables / Attributes in mails**
- 📆 **Drip campaigns**
- 📧 **Transactional emails**
- 📊 **Bounce, complaint, open and click tracking**
- ✅ **Subscribe and double opt-in**
- 🔗 **Webhook for Zapier, etc.**
- 🔌 **API with simple endpoints**
- 🔐 **Yubikey OTP security**
- 🎨 **Customizable templates**
- ⚙️ **Customizable settings**

## Flow Concepts

### Adding Users to a Flow
You can add a user to an ongoing flow, and the user will start at step one. This is useful for adding new users to a drip campaign. By using the API, you can also add the user to a specific step in the flow.

### Extending Flows
If a flow with 10 steps is completed and you add an additional step (11), the flow will continue for the users already in the flow. For a generic newsletter or tips & tricks flow, you can keep adding new steps, and users will continue to receive the new content.

### Managing Flows with Mail-Callbacks
Using the mail-callback, flows can be managed based on user actions. If a user clicks a link in the email, you can add the user to a new flow or step in the flow, or even when the user opens the email. This is useful for creating a more engaging flow.

## Dashboard

![dashboard](assets/screenshots/dashboard.png)

## Contacts

![contacts](assets/screenshots/contacts.png)

## Mail preview

![mail preview](assets/screenshots/mailpreview.png)

## Mail builder

![mailbuilder](assets/screenshots/mailbuilder.png)

## Flows / Drips

![flows](assets/screenshots/flows.png)

## Settings

![settings](assets/screenshots/settings.png)

**Reason for development**:

I needed a simple system to design and send out my newsletter, but also sending drip campaigns with tips and tricks when new users signed up. Besides those two core features, I also needed to keep track of bounces and complaints to maintain my domain reputation.

That was doable with the big players, but I wanted to have full control over the system and the user data (GDPR and syncing to my SaaS). So I ended up with something like Mailerlite for campaigns and Google templates for newsletters.

# 🚀 Startup

## Start the database
Create the database for starters (this for an new postgresql instance, otherwise use another username and password):
```sh
psql -U postgres -c "CREATE USER postgres WITH PASSWORD 'postgres';"
psql -U postgres -c "CREATE DATABASE nimletter_db OWNER postgres;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE nimletter_db TO postgres;"
```

### Option A) Docker / Podman compose
```sh
docker compose -f nimletter-compose.yaml up --detach
# or
podman compose -f nimletter-compose.yaml up --detach
```

### Option B) Run the container
__(Only database setup is needed)__
```sh
podman run \
  --name nimletter \
  --network host \
  --rm \
  -e PG_HOST=localhost:5432 \
  -e PG_USER=postgres \
  -e PG_PASSWORD=postgres \
  -e PG_DATABASE=nimletter_db \
  -e PG_WORKERS=3 \
  -e SMTP_HOST=smtp_host \
  -e SMTP_PORT=465 \
  -e SMTP_USER=smtp_username \
  -e SMTP_PASSWORD=smtp_password \
  -e SMTP_FROMEMAIL=admin@nimletter.com \
  -e SMTP_FROMNAME=ADMIN \
  -e SMTP_MAILSPERSECOND=1 \
  -e SNS_WEBHOOK_SECRET=secret \
  ghcr.io/thomastjdev/nimletter:latest
```

### Option C) Compile and run
__(See environment setup below for configuration)__
```sh
git clone
cd nimletter
nim c -d:release nimletter
# First run creates the database and inserts test data
./nimletter --DEV_RESET
./nimletter
```

### Option D) Systemd service file
```sh
cp nimletter.service ~/.config/systemd/user/
podman pull ghcr.io/thomastjdev/nimletter:latest
systemctl --user daemon-reload
systemctl --user start nimletter
systemctl --user status nimletter
systemctl --user enable nimletter
```

## Default credentials

The admin credentials default to:
```sh
email: admin@nimletter.com
password: dripit
```

You can override these by using environment variables:
```sh
-e ADMIN_EMAIL=admin@nimletter.com
-e ADMIN_PASSWORD=dripit
```

And within the system, you can customize the username and password. The password is hashed using salt and bcrypt, and you can even enable Yubikey OTP.

# 📧 SMTP

Nimletter is optimized for AWS SES but can be used with any SMTP server. The core part for managing bounces, complaints, and deliveries is done by the webhook endpoint. The formats can be seen in the `tests` folder.

If you are using AWS, just set up an SMTP Configuration, add relevant events, attach to an SNS topic, and point the webhook to the Nimletter endpoint.

__(The SNS_WEBHOOK_SECRET can also be set inside the settings page)__
```sh
/webhook/incoming/sns/" & getEnv("SNS_WEBHOOK_SECRET", "secret")
```

If the `SMTP_HOST` is specified as an environment variable, then it won't use the saved values in the database.

# 🌐 Environment variables
The values are customizable within the system and will be saved to the database.

**Database**
```sh
export PG_HOST=localhost
export PG_USER=postgres
export PG_PASSWORD=postgres
export PG_DATABASE=nimletter_db
export PG_WORKERS=3
```

**SMTP**
```sh
export SMTP_HOST=smtp_host
export SMTP_PORT=465
export SMTP_USER=smtp_username
export SMTP_PASSWORD=smtp_password
export SMTP_FROMEMAIL=admin@nimletter.com
export SMTP_FROMNAME=
export SMTP_MAILSPERSECOND=1
```

**SNS SECRET**
```sh
export SNS_WEBHOOK_SECRET=secret
```

**GEO**
__(Only relevant for binary, included in image)__
```sh
export GEOIP_PATH=/usr/share/GeoIP/GeoIP.dat
```

**Subscription**
The `ALLOW_GLOBAL_SUBSCRIPTION` is a global setting that allows users to subscribe at `/subscribe` without a specific list. The user will be added to the default list in this case. Default is `false`.
```sh
export ALLOW_GLOBAL_SUBSCRIPTION=true
```

# 🛠️ How to setup a postgres database manually
```sql
-- Step 1: Connect to PostgreSQL as a superuser
\c postgres;

-- Step 2: Create the user
CREATE USER postgres WITH PASSWORD 'postgres';

-- Step 3: Create the database
CREATE DATABASE nimletter_db OWNER postgres;

-- Step 4: Grant privileges to the user on the database
GRANT ALL PRIVILEGES ON DATABASE nimletter_db TO postgres;
```

or

```sh
psql -U postgres -c "CREATE USER postgres WITH PASSWORD 'postgres';"
psql -U postgres -c "CREATE DATABASE nimletter_db OWNER postgres;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE nimletter_db TO postgres;"
```

# 📚 Icons

https://heroicons.com/

# 📦 Libraries

* EmailbuilderJS by usewaypoint
* Tabulator by olifolkerd

# 🔜 Next

* Backend
  * Valkey (Redis) as caching for all DB values
  * Backup schedule checking (`checkAndSendScheduledEmails(backupCheck = true)`)
  * Move mail sending to another dedicated sender thread with synchronous channel (queue)
  * SQLite support
  * Moving JS to TypeScript
* User stuff
  * Captcha for subscribe
  * User managed pages for "subscribe" and "unsubscribe" and "optin"
