package com.hzm.flutter_contact_index

import android.content.Context
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Collections

class FlutterContactIndexHostImpl(val context: Context) : FlutterContactIndexHostApi {
  private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

  override fun getAllContacts(callback: (Result<List<ContactsModel>>) -> Unit) {
    scope.launch(Dispatchers.IO) {
      try {
        val contactList = ContactInfoService(context).contactList
        Collections.sort(contactList, comparator)
        val contactsModels = contactList.map { contactBean ->
          ContactsModel(
            contactBean.firstHeadLetter,
            displayName = contactBean.title,
            phoneList = contactBean.phoneInfoList,
            avatar = contactBean.avatar,
          )
        }.toList()
        // 当数据准备好后，切换回主线程以调用 Flutter 的回调
        withContext(Dispatchers.Main) {
          callback.invoke(Result.success(contactsModels))
        }
      } catch (e: Exception) {
        withContext(Dispatchers.Main) {
          callback.invoke(Result.failure(e))
        }
        Log.e(" NativeContactsService", e.toString())
      }
    }
  }

  fun cleanup() {
    scope.cancel() // 取消这个作用域启动的所有协程
  }

  var comparator: Comparator<ContactBean> = Comparator { o1, o2 ->
    val a = o1.firstHeadLetter
    val b = o2.firstHeadLetter
    val flag = a.compareTo(b)
    if (flag == 0) {
      a.compareTo(b)
    } else {
      flag
    }
  }
}