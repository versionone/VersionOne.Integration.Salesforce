global with sharing class ConnectionFactory implements IConnectionFactory {

	global IV1Connector getConnector() {
        Settings settings = new Settings();
        return new V1Connector(settings, new Requestor(settings));
	}
	global Settings getSettings() {
		return new Settings();
	}
}