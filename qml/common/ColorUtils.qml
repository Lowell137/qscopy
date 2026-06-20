import QtQuick

QtObject {
    function toColor(c) {
        if (typeof c === 'string') return Qt.darker(c, 1.0);
        return c;
    }

    function mix(color1, color2, percentage = 0.5) {
        if (typeof color1 === 'string') color1 = Qt.darker(color1, 1.0);
        if (typeof color2 === 'string') color2 = Qt.darker(color2, 1.0);
        if (!color1 || !color2) return color1 || color2 || Qt.rgba(0, 0, 0, 1);
        var p = Math.max(0, Math.min(1, percentage));
        return Qt.rgba(
            color1.r * (1 - p) + color2.r * p,
            color1.g * (1 - p) + color2.g * p,
            color1.b * (1 - p) + color2.b * p,
            1.0
        );
    }

    function transparentize(color, percentage = 1.0) {
        if (typeof color === 'string') color = Qt.darker(color, 1.0);
        if (!color) return Qt.rgba(0, 0, 0, 1);
        return Qt.rgba(color.r, color.g, color.b, color.a * (1 - Math.max(0, Math.min(1, percentage))));
    }

    function applyAlpha(color, alpha) {
        if (typeof color === 'string') color = Qt.darker(color, 1.0);
        if (!color) return Qt.rgba(0, 0, 0, alpha);
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    function blendWithAlpha(background, foreground) {
        if (typeof background === 'string') background = Qt.darker(background, 1.0);
        if (typeof foreground === 'string') foreground = Qt.darker(foreground, 1.0);
        if (!background || !foreground) return background || foreground || Qt.rgba(0, 0, 0, 1);
        var a = foreground.a;
        var inv = 1 - a;
        return Qt.rgba(
            foreground.r * a + background.r * inv,
            foreground.g * a + background.g * inv,
            foreground.b * a + background.b * inv,
            1.0
        );
    }

    function hexToRgba(hex, alpha = 1.0) {
        if (!hex || hex.length < 6) return Qt.rgba(0, 0, 0, alpha);
        var h = hex.replace("#", "");
        return Qt.rgba(
            parseInt(h.substring(0, 2), 16) / 255,
            parseInt(h.substring(2, 4), 16) / 255,
            parseInt(h.substring(4, 6), 16) / 255,
            alpha
        );
    }

    function surfaceAtElevation(surface, surfacePrimary, elevation) {
        var p = Math.min(1, elevation * 0.05);
        return mix(surface, surfacePrimary, p);
    }
}
