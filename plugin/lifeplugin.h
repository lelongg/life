/*
    SPDX-FileCopyrightText: 2022  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#ifndef LIFEPLUGIN_H
#define LIFEPLUGIN_H

#include <QQmlExtensionPlugin>

class lifePlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri) override;
};

#endif // LIFEPLUGIN_H
