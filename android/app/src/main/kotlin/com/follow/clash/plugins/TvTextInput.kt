package com.follow.clash.plugins

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.text.InputType
import android.view.WindowManager
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

class TvTextInput {
    private var dialog: AlertDialog? = null

    fun show(activity: Activity?, call: MethodCall, result: Result) {
        if (activity == null || activity.isFinishing || activity.isDestroyed) {
            result.error("ACTIVITY_UNAVAILABLE", "No active TV input window", null)
            return
        }
        if (dialog != null) {
            result.error("INPUT_BUSY", "A TV input window is already open", null)
            return
        }
        val configuration = call.argument<Map<String, Any?>>("configuration").orEmpty()
        val value = call.argument<Map<String, Any?>>("value").orEmpty()
        val input = configuration["inputType"] as? Map<*, *>
        val multiline = input?.get("name") == "TextInputType.multiline"
        val editor = EditText(activity).apply {
            isSingleLine = !multiline
            // setSingleLine replaces the transformation, so apply password masking after it.
            inputType = inputTypeFor(configuration)
            if (multiline) maxLines = 4
            imeOptions = EditorInfo.IME_FLAG_NO_EXTRACT_UI or EditorInfo.IME_ACTION_DONE
            setText(value["text"] as? String ?: "")
            val base = (value["selectionBase"] as? Number)?.toInt() ?: text.length
            val extent = (value["selectionExtent"] as? Number)?.toInt() ?: base
            setSelection(base.coerceIn(0, text.length), extent.coerceIn(0, text.length))
            val padding = (24 * resources.displayMetrics.density).toInt()
            setPadding(padding, padding, padding, padding)
        }
        var answer: Map<String, Any?>? = null
        val prompt = AlertDialog.Builder(activity)
            .setView(editor)
            .setPositiveButton(android.R.string.ok) { _, _ ->
                answer = mapOf(
                    "text" to editor.text.toString(),
                    "selectionBase" to editor.selectionStart,
                    "selectionExtent" to editor.selectionEnd,
                    "selectionAffinity" to "TextAffinity.downstream",
                    "selectionIsDirectional" to false,
                    "composingBase" to -1,
                    "composingExtent" to -1,
                )
            }
            .setNegativeButton(android.R.string.cancel, null)
            .create()
        prompt.setOnDismissListener {
            dialog = null
            result.success(answer)
        }
        editor.setOnEditorActionListener { _, action, _ ->
            if (action == EditorInfo.IME_ACTION_DONE) {
                prompt.getButton(AlertDialog.BUTTON_POSITIVE).performClick()
                true
            } else {
                false
            }
        }
        // Xiaomi's IME gate requires a focused native text editor on the window.
        editor.requestFocus()
        prompt.window?.setSoftInputMode(
            WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE or
                WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE,
        )
        dialog = prompt
        prompt.show()
        editor.post {
            if (prompt.isShowing && editor.hasFocus()) {
                val inputManager = activity.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                inputManager.showSoftInput(editor, InputMethodManager.SHOW_IMPLICIT)
            }
        }
    }

    fun dismiss() {
        dialog?.dismiss()
    }

    private fun inputTypeFor(configuration: Map<String, Any?>): Int {
        val input = configuration["inputType"] as? Map<*, *>
        if (configuration["obscureText"] == true) {
            return InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD
        }
        return when (input?.get("name")) {
            "TextInputType.number" -> InputType.TYPE_CLASS_NUMBER or
                (if (input["signed"] == true) InputType.TYPE_NUMBER_FLAG_SIGNED else 0) or
                (if (input["decimal"] == true) InputType.TYPE_NUMBER_FLAG_DECIMAL else 0)
            "TextInputType.phone" -> InputType.TYPE_CLASS_PHONE
            "TextInputType.datetime" -> InputType.TYPE_CLASS_DATETIME
            "TextInputType.emailAddress" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS
            "TextInputType.url" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_URI
            "TextInputType.multiline" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_MULTI_LINE
            else -> InputType.TYPE_CLASS_TEXT
        }
    }
}
