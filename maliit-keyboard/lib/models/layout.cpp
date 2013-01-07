/*
 * This file is part of Maliit Plugins
 *
 * Copyright (C) 2012 Openismus GmbH. All rights reserved.
 *
 * Contact: maliit-discuss@lists.maliit.org
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list
 * of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list
 * of conditions and the following disclaimer in the documentation and/or other materials
 * provided with the distribution.
 * Neither the name of Nokia Corporation nor the names of its contributors may be
 * used to endorse or promote products derived from this software without specific
 * prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include "layout.h"
#include "keyarea.h"
#include "key.h"
#include "keydescription.h"

#include "logic/layouthelper.h"
#include "logic/layoutupdater.h"

namespace MaliitKeyboard {
namespace Model {
namespace {
QUrl toUrl(const QString &directory,
            const QString &base_name)
{
    if (not (directory.isEmpty() || base_name.isEmpty())) {
        return QUrl(directory + "/" + base_name);
    }

    return QUrl();

}
}


class LayoutPrivate
{
public:
    KeyArea key_area;
    Logic::LayoutHelper *layout; // TODO: Get rid of this member.
    Logic::LayoutUpdater *updater; // TODO: wrap into scoped pointer and assign ownership to this class.
    QString image_directory;
    QHash<int, QByteArray> roles;

    explicit LayoutPrivate(Logic::LayoutUpdater *new_updater);
};


LayoutPrivate::LayoutPrivate(Logic::LayoutUpdater *new_updater)
    : key_area()
    , layout()
    , updater(new_updater)
    , image_directory()
    , roles()
{
    // Model roles are used as variables in QML, hence the under_score naming
    // convention:
    roles[Layout::RoleKeyRectangle] = "key_rectangle";
    roles[Layout::RoleKeyReactiveArea] = "key_reactive_area";
    roles[Layout::RoleKeyBackground] = "key_background";
    roles[Layout::RoleKeyBackgroundBorders] = "key_background_borders";
    roles[Layout::RoleKeyText] = "key_text";
}


Layout::Layout(Logic::LayoutUpdater *updater,
                                   QObject *parent)
    : QAbstractListModel(parent)
    , d_ptr(new LayoutPrivate(updater))
{}


Layout::~Layout()
{}


void Layout::setKeyArea(const KeyArea &area)
{
    beginResetModel();

    Q_D(Layout);
    const bool geometry_changed(d->key_area.rect() != area.rect());
    const bool background_changed(d->key_area.area().background() != area.area().background());
    const bool visible_changed((d->key_area.keys().isEmpty() && not area.keys().isEmpty())
                               || (not d->key_area.keys().isEmpty() && area.keys().isEmpty()));

    d->key_area = area;

    if (geometry_changed) {
        Q_EMIT widthChanged(width());
        Q_EMIT heightChanged(height());
    }

    if (background_changed) {
        Q_EMIT backgroundChanged(background());
    }

    if (visible_changed) {
        Q_EMIT visibleChanged(not d->key_area.keys().isEmpty());
    }

    endResetModel();
}


KeyArea Layout::keyArea() const
{
    Q_D(const Layout);
    return d->key_area;
}


void Layout::setLayout(Logic::LayoutHelper *layout)
{
    Q_D(Layout);

    d->layout = layout;
}


Logic::LayoutHelper *Layout::layout() const
{
    Q_D(const Layout);

    return d->layout;
}



bool Layout::isVisible() const
{
    Q_D(const Layout);
    return (not d->key_area.keys().isEmpty());
}


int Layout::width() const
{
    Q_D(const Layout);
    return d->key_area.rect().width();
}


int Layout::height() const
{
    Q_D(const Layout);
    return d->key_area.rect().height();
}


QUrl Layout::background() const
{
    Q_D(const Layout);
    return toUrl(d->image_directory, d->key_area.area().background());
}


void Layout::onExtendedKeysShown(const Key &key)
{
    Q_D(Layout);

    if (d->updater) {
        d->updater->onExtendedKeysShown(key);
    }
}


void Layout::setImageDirectory(const QString &directory)
{
    Q_D(Layout);

    if (d->image_directory != directory) {
        d->image_directory = directory;
        // TODO: Make sure we don't accidentially invalidate the whole model twice
        beginResetModel();
        backgroundChanged(background());
        endResetModel();
    }
}


int Layout::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    Q_D(const Layout);
    return d->key_area.keys().count();
}


QVariant Layout::data(const QModelIndex &index,
                                int role) const
{
    Q_D(const Layout);

    const QVector<Key> &keys(d->key_area.keys());
    const Key &key(index.row() < keys.count()
                   ? keys.at(index.row())
                   : Key());

    switch(role) {
    case RoleKeyReactiveArea:
        return QVariant(key.rect());

    case RoleKeyRectangle: {
        const QRect &r(key.rect());
        const QMargins &m(key.margins());

        return QVariant(QRectF(m.left(), m.top(),
                               r.width() - (m.left() + m.right()),
                               r.height() - (m.top() + m.bottom())));
    }

    case RoleKeyBackground:
        return QVariant(toUrl(d->image_directory, key.area().background()));

    case RoleKeyBackgroundBorders: {
        // Neither QML nor QVariant support QMargins type.
        // We need to transform QMargins into a QRectF so that we can abuse
        // left, top, right, bottom (of the QRectF) *as if* it was a QMargins.
        const QMargins &m(key.area().backgroundBorders());
        return QVariant(QRectF(m.left(), m.top(), m.right(), m.bottom()));
    }

    case RoleKeyText:
        return QVariant(key.label().text());
    }

    qWarning() << __PRETTY_FUNCTION__
               << "Invalid index or role (" << index.row() << role << ").";

    return QVariant();
}


QHash<int, QByteArray> Layout::roleNames() const
{
    Q_D(const Layout);
    return d->roles;
}


QVariant Layout::data(int index, const QString &role) const
{

    const QModelIndex idx(this->index(index, 0));
    return data(idx, roleNames().key(role.toLatin1()));
}


void Layout::onEntered(int index)
{
    Q_D(Layout);

    const QVector<Key> &keys(d->key_area.keys());
    const Key &key(index < keys.count()
                   ? keys.at(index)
                   : Key());

    if (d->updater) {
        d->updater->onKeyEntered(key);
    }

    Q_EMIT keyEntered(key);
}


void Layout::onExited(int index)
{
    Q_D(Layout);

    const QVector<Key> &keys(d->key_area.keys());
    const Key &key(index < keys.count()
                   ? keys.at(index)
                   : Key());

    if (d->updater) {
        d->updater->onKeyExited(key);
    }

    Q_EMIT keyExited(key);
}


void Layout::onPressed(int index)
{
    Q_D(Layout);

    const QVector<Key> &keys(d->key_area.keys());
    const Key &key(index < keys.count()
                   ? keys.at(index) : Key());
    const Key pressed_key(d->updater
                         ? d->updater->modifyKey(key, KeyDescription::PressedState) : Key());

    d->key_area.rKeys().replace(index, pressed_key);

    if (d->updater) {
        d->updater->onKeyPressed(pressed_key);
    }

    Q_EMIT dataChanged(this->index(index, 0), this->index(index, 0));
    Q_EMIT keyPressed(pressed_key);
}


void Layout::onReleased(int index)
{
    Q_D(Layout);

    const QVector<Key> &keys(d->key_area.keys());
    const Key &key(index < keys.count()
                   ? keys.at(index) : Key());
    const Key normal_key(d->updater
                         ? d->updater->modifyKey(key, KeyDescription::NormalState) : Key());

    d->key_area.rKeys().replace(index, normal_key);

    if (d->updater) {
        if (d->layout->activePanel() == Logic::LayoutHelper::ExtendedPanel) {
            d->updater->onExtendedKeySelected(normal_key);
        } else {
            d->updater->onKeyReleased(normal_key);
        }
    }

    Q_EMIT dataChanged(this->index(index, 0), this->index(index, 0));
    Q_EMIT keyReleased(normal_key);
}


void Layout::onPressAndHold(int index)
{
    Q_D(Layout);

    const QVector<Key> &keys(d->key_area.keys());
    const Key &key(index < keys.count()
                   ? keys.at(index)
                   : Key());

    // FIXME: long-press on space needs to work again to save words to dictionary!
    if (key.hasExtendedKeys()) {
        Q_EMIT extendedKeysShown(key);
    }

    Q_EMIT keyLongPressed(key);
}


}} // namespace Model, MaliitKeyboard
