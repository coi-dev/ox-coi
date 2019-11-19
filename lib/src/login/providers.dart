import 'package:flutter/material.dart';

class Providers {
  List<Provider> providerList;

  Providers({this.providerList});

  Providers.fromJson(Map<String, dynamic> json) {
    if (json['providers'] != null) {
      providerList = new List<Provider>();
      json['providers'].forEach((v) {
        providerList.add(new Provider.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.providerList != null) {
      data['providers'] = this.providerList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Provider {
  String id;
  String name;
  String registerLink;
  String pushServiceUrl;
  String inviteServiceUrl;
  Oauth oauth;
  Preset preset;

  Provider({this.id, this.name, this.oauth});

  Provider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    registerLink = json['register_link'];
    pushServiceUrl = json['push_service_url'];
    inviteServiceUrl = json['invite_service_url'];
    oauth = json['oauth'] != null ? new Oauth.fromJson(json['oauth']) : null;
    preset = json['preset'] != null ? new Preset.fromJson(json['preset']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['register_link'] = this.registerLink;
    data['push_service_url'] = pushServiceUrl;
    data['invite_service_url'] = inviteServiceUrl;
    if (this.oauth != null) {
      data['oauth'] = this.oauth.toJson();
    }
    if (this.preset != null) {
      data['preset'] = this.preset.toJson();
    }
    return data;
  }
}

class Preset {
  String incomingSecurity;
  String incomingServer;
  String incomingProtocol;
  int incomingPort;
  String outgoingSecurity;
  String outgoingServer;
  int outgoingPort;

  Preset(
      {this.incomingSecurity,
      this.incomingServer,
      this.incomingProtocol,
      this.incomingPort,
      this.outgoingSecurity,
      this.outgoingServer,
      this.outgoingPort});

  Preset.fromJson(Map<String, dynamic> json) {
    incomingSecurity = json['incoming_security'];
    incomingServer = json['incoming_server'];
    incomingProtocol = json['incoming_protocol'];
    incomingPort = json['incoming_port'];
    outgoingSecurity = json['outgoing_security'];
    outgoingServer = json['outgoing_server'];
    outgoingPort = json['outgoing_port'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['incoming_security'] = this.incomingSecurity;
    data['incoming_server'] = this.incomingServer;
    data['incoming_protocol'] = this.incomingProtocol;
    data['incoming_port'] = this.incomingPort;
    data['outgoing_security'] = this.outgoingSecurity;
    data['outgoing_server'] = this.outgoingServer;
    data['outgoing_port'] = this.outgoingPort;
    return data;
  }
}

class Oauth {
  String serviceId;
  String displayName;

  Oauth({this.serviceId, this.displayName});

  Oauth.fromJson(Map<String, dynamic> json) {
    serviceId = json['serviceId'];
    displayName = json['displayName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serviceId'] = this.serviceId;
    data['displayName'] = this.displayName;
    return data;
  }
}

int getSecurityId(String securityString) {
  switch (securityString) {
    case "ssltls":
      return 1;
    case "starttls":
      return 2;
    case "plain":
      return 3;
    default:
      return 0;
  }
}

String getProviderIconPath(BuildContext context, String id) {
  if (isCoiDebugProvider(id)) {
    id = "coi_debug";
  }
  var iconsBasePath = 'assets/images/';
  var logoPrefix = 'logo_';
  var fileType = '.png';
  return "$iconsBasePath$logoPrefix$id$fileType";
}

bool isCoiDebugProvider(String id) {
  return id.startsWith("coi_debug");
}
