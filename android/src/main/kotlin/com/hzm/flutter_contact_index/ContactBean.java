package com.hzm.flutter_contact_index;

import java.io.Serializable;
import java.util.Arrays;
import java.util.List;

public class ContactBean implements Serializable {
    private byte[] avatar;
    private String title;
    private List<PhoneInfo> phoneInfoList;
    private String firstHeadLetter;

    private String contactId;

    public ContactBean(byte[] avatar, String title, List<PhoneInfo> phoneInfoList, String firstHeadLetter, String contactId) {
        this.avatar = avatar;
        this.title = title;
        this.phoneInfoList = phoneInfoList;
        this.firstHeadLetter = firstHeadLetter;
        this.contactId = contactId;
    }

    public ContactBean() {

    }

    public byte[] getAvatar() {
        return avatar;
    }

    public String getFirstHeadLetter() {
        return firstHeadLetter;
    }

    public void setFirstHeadLetter(String firstHeadLetter) {
        this.firstHeadLetter = firstHeadLetter;
    }

    public void setAvatar(byte[] avatar) {
        this.avatar = avatar;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public List<PhoneInfo> getPhoneInfoList() {
        return phoneInfoList;
    }

    public void setPhoneInfoList(List<PhoneInfo> phoneInfoList) {
        this.phoneInfoList = phoneInfoList;
    }

    public String getContactId() {
        return contactId;
    }

    public void setContactId(String contactId) {
        this.contactId = contactId;
    }


    @Override
    public String toString() {
        return "ContactBean{" +
                "avatar=" + Arrays.toString(avatar) +
                ", title='" + title + '\'' +
                ", phoneInfoList='" + phoneInfoList + '\'' +
                ", contactId='" + contactId + '\'' +
                ", firstHeadLetter='" + firstHeadLetter + '\'' +
                '}';
    }
}
