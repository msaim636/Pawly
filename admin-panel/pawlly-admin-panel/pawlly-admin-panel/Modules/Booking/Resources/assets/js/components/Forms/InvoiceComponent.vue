<template>
  <template v-if="bookingData">
    <div class="offcanvas-header">

        <h4>{{ $t('booking.singular_title') }} #{{ bookingData.id }} <span class="text-capitalize">({{ bookingData.status }})</span></h4>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>

    </div>
    <div class="offcanvas-body">
      <div class="">
        <div class="d-flex align-items-start gap-3 mb-2">
          <img :src="bookingData.customer_image" alt="avatar" class="img-fluid avatar avatar-60 rounded-pill" />
          <div class="flex-grow-1">
            <div class="gap-2">
              <strong>{{ bookingData.customer_name }}</strong>
              <p class="m-0">
                <small>Client since {{ moment(bookingData.user_created).format('MMMM YYYY') }}</small>
              </p>
            </div>
          </div>
        </div>
      </div>
      <div class="form-group">

        <!-- <div v-for="(service, index) in bookingData.service" :key="index" class="py-2"> -->
          <div class="d-flex flex-column gap-1">
            <div class="d-flex align-items-center justify-content-between">
              <h6 class="m-0">{{ bookingData.service.name }}</h6>
              <div class="d-flex gap-3">
                <p class="m-0">{{ formatCurrencyVue(bookingData.price) }}</p>
              </div>
            </div>
            <p class="m-0">
              <label><i>With</i></label> <strong>{{ bookingData.employee_name }}</strong>
            </p>
          </div>
        <!-- </div> -->
      </div>
      <div class="border-top border-bottom py-3">
        <div class="d-flex justify-content-between align-items-center">
          <span>Payment Type</span>
          <span class="badge bg-primary"><strong>{{ bookingTransaction?.transaction_type??'-' }}</strong></span>
        </div>
        <div class="d-flex justify-content-between align-items-center">
          <span>Subtotal</span>
          <span><strong>{{ formatCurrencyVue(servicesTotal) }}</strong></span>
        </div>

        <div v-if="bookingTransaction && bookingTransaction.tax_percentage">
        <div class="d-flex justify-content-between align-items-center" v-for="(tax, index) in JSON.parse(bookingTransaction?.tax_percentage)" :key="index">
          <template v-if="tax.type == 'percentage'">

            <span>{{ tax.title }}:  {{ tax.value }}% </span>
            <span><strong>{{ formatCurrencyVue(calculatePercentAmount(tax.value)) }}</strong></span>
          </template>
          <template v-else>
            <span>{{ tax.title }}: </span>
            <span><strong>{{ formatCurrencyVue(tax.value) }}</strong></span>
          </template>
        </div>
        </div>

        <!-- <div class="d-flex justify-content-between align-items-center">
          <span>Tip Amount</span>
          <span><strong>{{ formatCurrencyVue(bookingTransaction?.tip_amount) }}</strong></span>
        </div> -->
      </div>
      <div class="d-flex justify-content-between align-items-center py-3 border-bottom">
        <h6 class="m-0">Final Total:</h6>
        <span><strong>{{ formatCurrencyVue(finalAmount) }}</strong></span>
      </div>
      <div class="py-3">
        <p><strong>Booking Detail</strong></p>
        <div>
          <h6><i class="fa-regular fa-clock"></i> Booked On {{ bookingData.created_at ?? '-' }}</h6>
        </div>
        <div class="">
          <h6><i class="fa-regular fa-user"></i> Booked By {{ bookingData.created_by_name ??'-'}}</h6>
        </div>
        <div class="mt-4">
          <h6><i class="fa-regular fa-clock"></i> Updated On {{ bookingData.updated_at ??'-' }}</h6>
        </div>
        <div class="">
          <h6><i class="fa-regular fa-user"></i> Updated By {{ bookingData.updated_by_name ??'-' }}</h6>
        </div>
      </div>
    </div>
  </template>
  <template v-else>
    <div class="offcanvas-header">
      <div>
        <h4>{{ $t('booking.singular_title') }} #0 <span class="text-capitalize">(___________)</span></h4>
      </div>
    </div>
  </template>
</template>
<script setup>
import {ref, onMounted, computed} from 'vue'
import {BOOKING_DETAIL} from '../../constant/booking'
import { useRequest } from '@/helpers/hooks/useCrudOpration'
import * as moment from 'moment'

const { getRequest } = useRequest()
const props = defineProps({
  booking_id: {required: true}
})
const formatCurrencyVue = (value) => {
  if (window.currencyFormat !== undefined) {
    return window.currencyFormat(value)
  }
  return value
}
const bookingData = ref(null)
const servicesTotal = ref(0)
const bookingTransaction = ref(null)
const calculatePercentAmount = (percent) => {
  const percentAmount = (servicesTotal.value * percent) / 100;
  return percentAmount
}
const taxAmount = computed(() => {
  let totalTaxAmount = 0;

  if (bookingTransaction.value !== null) {
    const taxes = JSON.parse(bookingTransaction.value.tax_percentage);

    for (const tax of taxes) {
      const taxValue = parseFloat(tax.value); 

      if (tax.type === 'percentage') {
        totalTaxAmount += (servicesTotal.value * taxValue) / 100;
      } else {
        totalTaxAmount += taxValue;
      }
    }
    return totalTaxAmount.toFixed(2);
  }

  return totalTaxAmount.toFixed(2);
});

const finalAmount = computed(() => {
  return Number(servicesTotal.value) + Number(taxAmount.value)
})

onMounted(() => {
  getRequest({url: BOOKING_DETAIL, id: props.booking_id}).then((res) => {
    if(res.status) {

      bookingData.value = res.data.booking
      servicesTotal.value = res.data.booking.price
      bookingTransaction.value = res.data.booking_transaction
    }
  })
})
</script>
