package com.example.dom_affrikia_app

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "activation_codes.db"
        private const val DATABASE_VERSION = 1
        const val TABLE_NAME = "codes"
        const val COLUMN_ID = "id"
        const val COLUMN_CODE = "code"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createTableQuery = "CREATE TABLE $TABLE_NAME ($COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT, $COLUMN_CODE TEXT UNIQUE)"
        db.execSQL(createTableQuery)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_NAME")
        onCreate(db)
    }

    fun insertCode(code: String): Boolean {
        val db = this.writableDatabase
        val values = ContentValues()
        values.put(COLUMN_CODE, code)

        val result = db.insert(TABLE_NAME, null, values)
        db.close()
        return result != -1L
    }

    fun checkCodeExists(code: String): Boolean {
        val db = this.readableDatabase
        val query = "SELECT * FROM $TABLE_NAME WHERE $COLUMN_CODE = ?"
        val cursor = db.rawQuery(query, arrayOf(code))
        val exists = cursor.count > 0
        cursor.close()
        db.close()
        return exists
    }
}