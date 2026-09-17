<template>

<div class="d-flex  align-items-center justify-content-between">
  <UserTypeSelector
                    :initial-user-type="userType"
                    @userTypeChanged="onUserTypeChanged" />

                <div class="pagination-controls">
                  <nav aria-label="Pagination mb-0">
                    <ul class="pagination">
                          <li class="page-item">
                            <button @click="prevPage" :disabled="currentPage === 1" class="page-link">Previous</button>
                          </li>{{ ' ' }}
                            <span>Page {{ currentPage}}</span>
                          <li class="page-item">
                            <button @click="nextPage" class="page-link">Next</button>
                          </li>
                    </ul>
                  </nav>
                </div>
</div>

<div ref="calenderRef" class="position-relative">
    <div v-if="isLoading" class="loader-overlay">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    </div>
  </div>

  <BookingForm
  v-if="userType === 'boarder'"
  :booking-type="bookingType"
                :status-list="bookingStatus"
                @onSubmit="onSubmitEvent"
                :booking-data="bookingData"
                ></BookingForm>


  <GroomerBookingForm
 v-if="userType === 'groomer'"
  :booking-type="bookingType"
                :status-list="bookingStatus"
                @onSubmit="onSubmitEvent"
                :booking-data="bookingData"
                ></GroomerBookingForm>

    <DaycareBookingForm
    v-if="userType === 'day_taker'"
    :booking-type="bookingType"
    :status-list="bookingStatus"
    @onSubmit="onSubmitEvent"
    :booking-data="bookingData"
    ></DaycareBookingForm>

    <TrainerBookingForm
    v-if="userType === 'trainer'"
    :booking-type="bookingType"
    :status-list="bookingStatus"
    @onSubmit="onSubmitEvent"
    :booking-data="bookingData"
    ></TrainerBookingForm>

    <WalkerBookingForm
    v-if="userType === 'walker'"
    :booking-type="bookingType"
    :status-list="bookingStatus"
    @onSubmit="onSubmitEvent"
    :booking-data="bookingData"
    ></WalkerBookingForm>

    <VetBookingForm
    v-if="userType === 'vet'"
    :booking-type="bookingType"
    :status-list="bookingStatus"
    @onSubmit="onSubmitEvent"
    :booking-data="bookingData"
    ></VetBookingForm>

</template>
<script setup>
import { reactive, ref, onMounted, onUnmounted, watch } from 'vue'
import { createRequest } from '@/helpers/utilities'
import UserTypeSelector from './UserTypeSelector.vue'
import Calendar from '@event-calendar/core'
import DayGrid from '@event-calendar/day-grid'
import List from '@event-calendar/list'
import TimeGrid from '@event-calendar/time-grid'
import ResourceTimeGrid from '@event-calendar/resource-time-grid'
import Interaction from '@event-calendar/interaction'
const isLoading = ref(true);
const user_type = ref('');
const userType = ref('boarder');

// Import different forms for different booking types
import BoardingBookingForm from './BookingForm.vue'
import DaycareBookingForm from './DayCareBookingForm.vue'
import GroomerBookingForm from './GroomerBookingForm.vue'
import TrainerBookingForm from './TrainerBookingForm.vue'
import VetBookingForm from './VatBookingForm.vue'
import WalkerBookingForm from './WalkerBookingForm.vue'


const currentPage = ref(1);
const perPage = ref(6);
import BookingForm from './BookingForm.vue'
import { INDEX_URL } from '../constant/booking'
import * as moment from 'moment'
const totalEmployees = ref(0)

const props = defineProps({
  status: { type: String, required: true },
  slotDuration: { type: String },
  branchId: {type: [String , Number]},
  date: new Date()
})

let slotsDurations = '00:15'
if(props.slotDuration !== '') {
  slotsDurations = props.slotDuration
}
const bookingStatus = ref(JSON.parse(props.status))
const calenderRef = ref(null)
const calenderInit = ref(null)
const bookingType = ref('')
const bookingData = reactive({
  id: 0,
  start_date_time: null,
  employee_id: null,
  branch_id: props.branchId
})




const setBooking = (info) => {
  bookingData.id = info.id || 0
  bookingData.employee_id = info?.resource?.id || null
  bookingData.start_date_time = info.date || null

}


const onUserTypeChanged = (newUserType) => {
  userType.value = newUserType;
  isLoading.value = true;
  if (calenderInit.value) {
    calenderInit.value.refetchEvents();
  }
};


watch(  () => userType.value,
(value) =>{
  const elem=ref(null);
  switch (userType.value) {
    case 'boarder':
    elem.value = document.querySelector('.border-booking')
    break
    case 'day_taker':
    elem.value = document.querySelector('.DayCareBooking');
    break
    case 'groomer':
    elem.value = document.querySelector('.GroomerBooking');
    break
    case 'walker':
    elem.value = document.querySelector('.walker-booking');
    break
    case 'trainer':
    elem.value = document.querySelector('.trainer-booking');
    break
    case 'vet':
    elem.value = document.querySelector('.vat-booking');
    break
    default:
    break
  }
  if(elem.value !== null) {
    elem.value.addEventListener('hide.bs.offcanvas', function() {
      setBooking({})
      updateBodyClass('hide')
      bookingType.value = ''
    })
    const bkid = new URL(location.href).searchParams.get('booking_id')
    if(bkid !== null && bkid !== undefined) {
      bookingType.value = 'CALENDER_BOOKING'
      showBookingForm({id: bkid})
    }
  }

})


const showBookingForm = (info) => {
  bookingType.value = 'CALENDER_BOOKING'
  setBooking(info)

const elemSelector = {
  'boarder': '.border-booking',
  'day_taker': '.DayCareBooking',
  'groomer': '.GroomerBooking',
  'walker': '.walker-booking',
  'trainer': '.trainer-booking',
  'vet': '.vat-booking'
};

const selector = elemSelector[userType.value];
const elem = document.querySelector(selector);

  const removeBackdrop = () => {
  document.querySelector('.offcanvas-backdrop')?.remove();
  updateBodyClass('show');
};

if (elem) {
    const form = bootstrap.Offcanvas.getOrCreateInstance(elem);
    form.show();

    const removeBackdrop = () => {
      document.querySelector('.offcanvas-backdrop')?.remove();
      updateBodyClass('show');
    };

    // form.addEventListener('shown.bs.offcanvas', removeBackdrop);
    // form.addEventListener('hide.bs.offcanvas', () => {
    //   setBooking({});
    //   updateBodyClass('hide');
    //   bookingType.value = '';
    // });
  }
}

const hideBookingForm = () => {
  const elem = document.getElementById('form-offcanvas')
  const form = bootstrap.Offcanvas.getOrCreateInstance(elem)
  form.hide()
  updateBodyClass('hide')
}

const updateBodyClass = (value = 'hide') => {
  if(value == 'show') {
    document.body.classList.add('calender-view')
  } else {
    document.body.classList.remove('calender-view')
  }
}

const createBooking = () => {
  bookingType.value = 'CREATE_BOOKING'
  showBookingForm({})
}
onUnmounted(() => {
  const selector = {
    'boarder': '.border-booking',
    'day_taker': '.DayCareBooking',
    'groomer': '.GroomerBooking',
    'walker': '.walker-booking',
    'trainer': '.trainer-booking',
    'vet': '.vat-booking'
  };

  const elem = document.querySelector(selector[userType.value]);
  if (elem) {
    const form = bootstrap.Offcanvas.getOrCreateInstance(elem);
    form.hide();
    updateBodyClass('hide');
    form.removeEventListener('hide.bs.offcanvas', () => {
      setBooking({});
      updateBodyClass('hide');
      bookingType.value = '';
    });
  }
})

onMounted(() => {

  const elemSelector = {
  'boarder': '.border-booking',
  'day_taker': '.DayCareBooking',
  'groomer': '.GroomerBooking',
  'walker': '.walker-booking',
  'trainer': '.trainer-booking',
  'vet': '.vat-booking'
};

const selector = elemSelector[userType.value];
const elem = document.querySelector(selector);

  if(elem !== null) {
    elem.addEventListener('hide.bs.offcanvas', function() {
      setBooking({})
      updateBodyClass('hide')
      bookingType.value = ''
    })
    const bkid = new URL(location.href).searchParams.get('booking_id')
    if(bkid !== null && bkid !== undefined) {
      bookingType.value = 'CALENDER_BOOKING'
      showBookingForm({id: bkid})
    }
  }
  if (calenderRef !== null) {
    calenderInit.value = new Calendar({
      target: calenderRef.value,
      props: {
        plugins: [DayGrid, List, TimeGrid, ResourceTimeGrid, Interaction],
        options: {
          date: props.date,
          slotEventOverlap: false,
          dragScroll: false,
          view: 'resourceTimeGridDay',
          height: '800px',
          headerToolbar: {
            start: 'prev,next today',
            center: 'title',
            end: 'resourceTimeGridDay'
            // dayGridMonth,timeGridWeek,timeGridDay,listWeek
          },
          buttonText: function (texts) {
            texts.resourceTimeGridDay = 'Day'
            texts.resourceTimeGridWeek = 'Week'
            return texts
          },
          eventContent: function (data) {
            if(data.event.titleHTML !== undefined) {
              return {html: data.event.titleHTML + data.timeText}
            }
            return data.timeText
          },
          slotLabelFormat: function (data) {
            // Convert the input string to a Date object
            const date = new Date(data);

            // Get the hour and minute from the Date object
            const minute = data.getMinutes();

            // Check if the hour and minute are both "00"
            if (minute === 0) {
              return moment(data).format('hh:mm A');
            } else {
              return '';
            }
          },
          resources: [],
          scrollTime: '09:00:00',
          events: [],
          views: {
            timeGridWeek: { pointer: true },
            resourceTimeGridWeek: { pointer: true },
            resourceTimeGridDay: { pointer: true }
          },
          eventSources: [
            {
              events: async function () {
              const params = {
                user_type: userType.value,
                page: currentPage.value,
                per_page: perPage.value
              };
              const events = await createRequest(INDEX_URL(params)).then((res) => {
                const { employees, data } = res;
                totalEmployees.value = res.total_count
                calenderInit.value.setOption('resources', employees);
                isLoading.value = false;
                return data;
              });
                return events
              }
            }
          ],
          dateClick: function (info) {
            showBookingForm(info)
          },
          select: function (info) {
            showBookingForm(info)
          },
          eventClick: function (info) {

            const updatedInfo = {
              id: info.event.id,
              resource: {id: info.event.resourceIds[0]},
              date: info.event.start
            }
            showBookingForm(updatedInfo)
          },
          eventStartEditable: false,
          slotDuration: slotsDurations,
          dayMaxEvents: true,
          nowIndicator: true,
          selectable: false
        }
      }
    })
  }
})


const prevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
    calenderInit.value.refetchEvents()
  }
}

const nextPage = () => {
  if (currentPage.value * perPage.value < totalEmployees.value) {
    currentPage.value++
    calenderInit.value.refetchEvents()
  }
}


const onSubmitEvent = () => {
  calenderInit.value.refetchEvents()
}

</script>
<style >
@import '@event-calendar/core/index.css';
body {
  transition: width 400ms ease;
}
.calender-view {
  width: calc(100% - 382px);
  transition: width 400ms ease;
}
.ec-lines {
  width: unset;
  margin-left: 8px;
}
.booking-datepicker .flatpickr-wrapper{
  width: 100% !important;
  display: block;
}
.ec-header .ec-day {
  overflow: inherit !important;
  height: inherit !important;
  line-height: inherit;
  min-height: inherit;
}
.ec-day.ec-today {
  background-color: var(--bs-body-bg);
}
.dark .ec-day.ec-today {
  background-color: #181818;
}
.ec-event{
  border-radius: 0;
  border-bottom: 2px solid var(--bs-border-color);
  cursor: pointer;
}
.ec-body:not(.ec-compact) .ec-line:nth-child(even):after{
  border-bottom-style: solid;
}
.ec-line:not(:first-child):after {
  border-color: var(--bs-border-color);
}
.ec-header,.ec-all-day,.ec-body,.ec-days,.ec-day{
  border-color: var(--bs-border-color);
}
.ec-button, .ec-button:not(:disabled) {
  color: var(--bs-body-color);
  background-color: var(--bs-body-bg);
  border-color: var(--bs-border-color);
}
.dark .ec-button:not(:disabled):hover, .dark .ec-button.ec-active {
  border-color: var(--bs-border-color);
  background-color: var(--bs-body-bg);
}
.ec-icon.ec-prev:after, .ec-icon.ec-next:after {
  border-color: var(--bs-body-color);
}

.loader-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.8);
  z-index: 10;
}

.flatpickr-calendar.hasTime.open {
  right: 28px !important;
}

</style>
