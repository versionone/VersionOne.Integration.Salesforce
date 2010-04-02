global class ConnectionFactoryMock implements IConnectionFactory {
    private final Settings settingsData;
    private final IV1Connector connection;

    public ConnectionFactoryMock(Settings settingsData, IV1Connector connection) {
        this.settingsData = settingsData;
        this.connection = connection;
    }

    global IV1Connector getConnector() {
        return connection;
    }
    global Settings getSettings() {
        return settingsData;
    }
}