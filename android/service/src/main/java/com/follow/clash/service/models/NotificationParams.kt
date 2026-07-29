package com.follow.clash.service.models

import android.os.Parcel
import android.os.Parcelable

data class NotificationParams(
    val title: String = "flclash++",
    val stopText: String = "STOP",
    val onlyStatisticsProxy: Boolean = false,
) : Parcelable {
    constructor(parcel: Parcel) : this(
        title = parcel.readString() ?: "flclash++",
        stopText = parcel.readString() ?: "STOP",
        onlyStatisticsProxy = parcel.readByte() != 0.toByte(),
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(title)
        parcel.writeString(stopText)
        parcel.writeByte(if (onlyStatisticsProxy) 1.toByte() else 0.toByte())
    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<NotificationParams> {
        override fun createFromParcel(parcel: Parcel): NotificationParams {
            return NotificationParams(parcel)
        }

        override fun newArray(size: Int): Array<NotificationParams?> {
            return arrayOfNulls(size)
        }
    }
}
