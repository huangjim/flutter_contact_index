package com.hzm.flutter_contact_index;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.provider.ContactsContract;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

/**
 * 用于返回读取到联系人的集合
 */
public class ContactInfoService {
    private Context context;

    public ContactInfoService(Context context) {
        this.context = context;
    }

    public ArrayList<ContactBean> getContactList() {

        ArrayList<ContactBean> mContactBeanList = new ArrayList<>();
        ContactBean mContactBean;
        ContentResolver mContentResolver = context.getContentResolver();
        Uri uri = Uri.parse("content://com.android.contacts/raw_contacts");
        Uri dataUri = Uri.parse("content://com.android.contacts/data");

        Cursor cursor = mContentResolver.query(uri, null, null, null, null);
        if (cursor == null) {
            return mContactBeanList;
        }
        while (cursor.moveToNext()) {
            mContactBean = new ContactBean();
            String id = cursor.getString(cursor.getColumnIndex("_id"));
            String title = cursor.getString(cursor.getColumnIndex("display_name"));//获取联系人姓名
            String firstHeadLetter = cursor.getString(cursor.getColumnIndex("phonebook_label"));//这个字段保存了每个联系人首字的拼音的首字母
            mContactBean.setTitle(title);
            mContactBean.setFirstHeadLetter(firstHeadLetter);

            int columnIndex = cursor.getColumnIndex(ContactsContract.Data.CONTACT_ID);
            String contactId = cursor.getString(columnIndex);
            mContactBean.setContactId(contactId);
            Log.i("ContactInfoService", "id = " + id + ", contactId = " + contactId);

            // 读取联系人头像
            byte[] avatarBytes = loadContactPhotoHighRes(contactId, true, mContentResolver);
            mContactBean.setAvatar(avatarBytes); // 假设ContactBean类有setAvatar方法

            Cursor dataCursor = mContentResolver.query(dataUri, null, "raw_contact_id= ?", new String[]{id}, null);
            List<PhoneInfo> phoneInfoList = new ArrayList<>();
            // 为了提高效率，在循环外先获取列的索引
            if (dataCursor != null) {
                int mimeTypeColumn = dataCursor.getColumnIndex("mimetype");
                int data1Column = dataCursor.getColumnIndex("data1"); // Phone number
                int data2Column = dataCursor.getColumnIndex("data2"); // Phone type (integer)
                int data3Column = dataCursor.getColumnIndex("data3"); // Custom label string
                while (dataCursor.moveToNext()) {
//                String type = dataCursor.getString(dataCursor.getColumnIndex("mimetype"));
                    String mimeType = dataCursor.getString(mimeTypeColumn);
                    if (mimeType.equals("vnd.android.cursor.item/phone_v2")) {//如果得到的mimeType类型为手机号码类型才去接收
//                    String phoneNum = dataCursor.getString(dataCursor.getColumnIndex("data1"));//获取手机号码
                        String phoneNum = dataCursor.getString(data1Column);
                        int phoneType = dataCursor.getInt(data2Column);
                        String label;

                        // 根据 phoneType 整数，将其映射为和 iOS 一致的字符串标签
                        switch (phoneType) {
                            case ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE:
                                label = "mobile";
                                break;
                            case ContactsContract.CommonDataKinds.Phone.TYPE_HOME:
                                label = "home";
                                break;
                            case ContactsContract.CommonDataKinds.Phone.TYPE_WORK:
                                label = "work";
                                break;
                            case ContactsContract.CommonDataKinds.Phone.TYPE_MAIN:
                                label = "main";
                                break;
                            case ContactsContract.CommonDataKinds.Phone.TYPE_CUSTOM:
                                // 如果是自定义类型，真正的标签存储在 data3 列
                                label = dataCursor.getString(data3Column);
                                if (label == null) {
                                    label = "other"; // 防止自定义标签为空
                                }
                                break;
                            default:
                                // 其他所有类型 (如 FAX, PAGER 等) 都归为 "other"
                                // 注意：Android 没有与 iOS 中 "iPhone" 完全对应的类型
                                label = "other";
                                break;
                        }
                        phoneInfoList.add(new PhoneInfo(label, phoneNum));
                    }
                }
                mContactBean.setPhoneInfoList(phoneInfoList);
                dataCursor.close();
            }
            if (mContactBean.getTitle() != null && mContactBean.getPhoneInfoList() != null && !mContactBean.getPhoneInfoList().isEmpty()) {
                mContactBeanList.add(mContactBean);
            }

        }
        cursor.close();
        return mContactBeanList;
    }

    private static byte[] loadContactPhotoHighRes(final String identifier,
                                                  final boolean photoHighResolution, final ContentResolver contentResolver) {
        try {

//            cursor.getColumnIndex(ContactsContract.Data.CONTACT_ID);

            final Uri uri = ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, Long.parseLong(identifier));
            final InputStream input = ContactsContract.Contacts.openContactPhotoInputStream(contentResolver, uri, photoHighResolution);

            if (input == null) return null;

            final Bitmap bitmap = BitmapFactory.decodeStream(input);
            input.close();

            final ByteArrayOutputStream stream = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
            final byte[] bytes = stream.toByteArray();
            stream.close();
            return bytes;
        } catch (final IOException ex) {
            Log.e("ContactInfoService", ex.getMessage());
            return null;
        }
    }
}