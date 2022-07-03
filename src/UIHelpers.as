void DisabledButton(const string &in text, const vec2 &in size = vec2 ( )) {
    UI::BeginDisabled();
    UI::Button(text, size);
    UI::EndDisabled();
}

bool MDisabledButton(bool disabled, const string &in text, const vec2 &in size = vec2 ( )) {
    if (disabled) {
        DisabledButton(text, size);
        return false;
    } else {
        return UI::Button(text, size);
    }
}
