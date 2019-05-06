from django import forms
from django.core.exceptions import ValidationError
import datetime


class RawVisaForm(forms.Form):

    credit_number = forms.CharField()
    expiry = forms.DateField()

    def set_form_data(self, data):
        i = 0
        for field in self.fields.values():
            field.initial = data[i]
            i += 1

    def clean(self):
        first_two_digits = self.cleaned_data['credit_number'][0:2]
        if first_two_digits not in ['40', '41', '51', '55']:
            raise ValidationError('Invalid credit card number, please enter a visa or a mastercard')

        if datetime.datetime.now().date() > self.cleaned_data['expiry']:
            raise ValidationError('This card has expired, please enter a valid card')

