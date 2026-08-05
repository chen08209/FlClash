package com.follow.clash.service

import android.database.Cursor
import android.database.MatrixCursor
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract
import android.provider.DocumentsProvider
import com.follow.clash.common.R as CommonR
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException

class FilesProvider : DocumentsProvider() {
    override fun onCreate() = true

    override fun queryRoots(projection: Array<String>?): Cursor =
        MatrixCursor(projection ?: DEFAULT_ROOT_COLUMNS).apply {
            newRow()
                .add(DocumentsContract.Root.COLUMN_ROOT_ID, DEFAULT_ROOT_ID)
                .add(DocumentsContract.Root.COLUMN_FLAGS, DocumentsContract.Root.FLAG_LOCAL_ONLY)
                .add(DocumentsContract.Root.COLUMN_ICON, R.drawable.ic_service)
                .add(
                    DocumentsContract.Root.COLUMN_TITLE,
                    context?.getString(CommonR.string.app_name).orEmpty(),
                )
                .add(DocumentsContract.Root.COLUMN_DOCUMENT_ID, ROOT_DOCUMENT_ID)
        }

    override fun queryChildDocuments(
        parentDocumentId: String,
        projection: Array<String>?,
        sortOrder: String?,
    ): Cursor {
        val result = MatrixCursor(projection ?: DEFAULT_DOCUMENT_COLUMNS)
        val parentFile = resolveFile(parentDocumentId)
        parentFile.listFiles()?.forEach { file ->
            includeFile(result, file)
        }
        return result
    }

    override fun queryDocument(documentId: String, projection: Array<String>?): Cursor {
        val result = MatrixCursor(projection ?: DEFAULT_DOCUMENT_COLUMNS)
        includeFile(result, resolveFile(documentId))
        return result
    }

    override fun openDocument(
        documentId: String,
        mode: String,
        signal: CancellationSignal?,
    ): ParcelFileDescriptor {
        val accessMode = ParcelFileDescriptor.parseMode(mode)
        return ParcelFileDescriptor.open(resolveFile(documentId), accessMode)
    }

    private fun includeFile(result: MatrixCursor, file: File) {
        result.newRow().apply {
            add(DocumentsContract.Document.COLUMN_DOCUMENT_ID, file.absolutePath)
            add(DocumentsContract.Document.COLUMN_DISPLAY_NAME, file.name)
            add(DocumentsContract.Document.COLUMN_SIZE, file.length())
            val flags = if (file.isFile) {
                DocumentsContract.Document.FLAG_SUPPORTS_WRITE
            } else {
                0
            }
            val mimeType = if (file.isDirectory) {
                DocumentsContract.Document.MIME_TYPE_DIR
            } else {
                "application/octet-stream"
            }
            add(DocumentsContract.Document.COLUMN_FLAGS, flags)
            add(DocumentsContract.Document.COLUMN_MIME_TYPE, mimeType)
        }
    }

    private fun resolveFile(documentId: String): File {
        val root = context?.filesDir?.canonicalFile
            ?: throw FileNotFoundException("App files directory is unavailable")
        val file = try {
            if (documentId == ROOT_DOCUMENT_ID) root else File(documentId).canonicalFile
        } catch (error: IOException) {
            throw FileNotFoundException(error.message).apply { initCause(error) }
        }
        val isInsideRoot = file == root || file.path.startsWith("${root.path}${File.separator}")
        if (!isInsideRoot) {
            throw FileNotFoundException("Document is outside the app files directory")
        }
        return file
    }

    private companion object {
        const val DEFAULT_ROOT_ID = "0"
        const val ROOT_DOCUMENT_ID = "/"

        val DEFAULT_DOCUMENT_COLUMNS = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
            DocumentsContract.Document.COLUMN_FLAGS,
            DocumentsContract.Document.COLUMN_SIZE,
        )
        val DEFAULT_ROOT_COLUMNS = arrayOf(
            DocumentsContract.Root.COLUMN_ROOT_ID,
            DocumentsContract.Root.COLUMN_FLAGS,
            DocumentsContract.Root.COLUMN_ICON,
            DocumentsContract.Root.COLUMN_TITLE,
            DocumentsContract.Root.COLUMN_SUMMARY,
            DocumentsContract.Root.COLUMN_DOCUMENT_ID,
        )
    }
}
