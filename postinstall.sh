
#!/bin/bash

# Voer eerst het Perl-script uit dat eventueel extra taken uitvoert
# perl /opt/loxberry/bin/plugins/ozw672_plugin/create_cronjob.pl

echo "MyPlugin installed successfully!" >> /opt/loxberry/log/plugins/ozw672_plugin/install.log

# Controleer of /usr/local/bin/httpsrequest.pl al bestaat, zo ja: eigenaar wijzigen en uitvoerbaar maken.
if [ -f "/usr/local/bin/httpsrequest.pl" ]; then
    sudo chown loxberry:loxberry "/usr/local/bin/httpsrequest.pl"
    sudo chmod 755 "/usr/local/bin/httpsrequest.pl"
    echo "Set ownership to loxberry:loxberry and permissions to 755 for /usr/local/bin/httpsrequest.pl" >> /opt/loxberry/log/plugins/ozw672_plugin/install.log
else
    echo "File /usr/local/bin/httpsrequest.pl not found" >> /opt/loxberry/log/plugins/ozw672_plugin/install.log
fi

#############################
# Stap 1: Kopieer ozw672_script.pl naar /usr/local/bin
#############################
SOURCE_PATH="./bin/ozw672_script.pl"
DESTINATION_PATH="/usr/local/bin/ozw672_script.pl"
LOG_FILE="/opt/loxberry/log/plugins/ozw672_plugin/log.txt"
CRON_FILE="ozw672_plugin"  # Naam voor het tijdelijke cronbestand

echo "$(date '+%Y-%m-%d %H:%M:%S') - Running MyPlugin Script" >> "$LOG_FILE"

if sudo cp "$SOURCE_PATH" "$DESTINATION_PATH"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ozw672_script.pl has been copied to $DESTINATION_PATH" >> "$LOG_FILE"
    # Zet eigendom en rechten
    sudo chown loxberry:loxberry "$DESTINATION_PATH"
    sudo chmod 755 "$DESTINATION_PATH"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Set ownership to loxberry:loxberry and permissions to 755 for $DESTINATION_PATH" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to copy ozw672_script.pl to $DESTINATION_PATH" >> "$LOG_FILE"
    exit 1
fi

#############################
# Stap 2: Kopieer httpsrequest.pl naar /usr/local/bin
#############################
SOURCE_PATH="./bin/httpsrequest.pl"
DESTINATION_PATH="/usr/local/bin/httpsrequest.pl"

if sudo cp "$SOURCE_PATH" "$DESTINATION_PATH"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - httpsrequest.pl has been copied to $DESTINATION_PATH" >> "$LOG_FILE"
    # Zet eigendom en rechten
    sudo chown loxberry:loxberry "$DESTINATION_PATH"
    sudo chmod 755 "$DESTINATION_PATH"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Set ownership to loxberry:loxberry and permissions to 755 for $DESTINATION_PATH" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to copy httpsrequest.pl to $DESTINATION_PATH" >> "$LOG_FILE"
    exit 1
fi

#############################
# Stap 3: Installeer indien gewenst de cronjob via wrapper script of extra logic
#############################
echo "$(date '+%Y-%m-%d %H:%M:%S') - MyPlugin Script completed" >> "$LOG_FILE"