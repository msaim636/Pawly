<!-- UserTypeSelector.vue -->
<template>
  <div class="col-md-6 form-group">
    <label class="form-label" for="user_type">{{ $t('employee.lbl_select_user_type') }}</label> <span class="text-danger">*</span>
    <select class="form-select" v-model="userType" @change="onUserTypeChange">
      <option value="vet">{{ $t('employee.vet') }}</option>
      <option value="trainer">{{ $t('employee.trainer') }}</option>
      <option value="groomer">{{ $t('employee.groomer') }}</option>
      <option value="walker">{{ $t('employee.walker') }}</option>
      <option value="boarder">{{ $t('employee.boarder') }}</option>
      <option value="day_taker">{{ $t('employee.day_taker') }}</option>
      <option v-if="enableMultiVendor" value="pet_store">{{ $t('employee.pet_store') }}</option>
    </select>
  </div>
</template>

<script setup>
import { ref, defineProps, defineEmits } from 'vue';

const props = defineProps({
  enableMultiVendor: Boolean,
  initialUserType: {
    type: String,
    default: 'boarder'
  }
});

const emits = defineEmits(['userTypeChanged']);

const userType = ref(props.initialUserType);

const onUserTypeChange = () => {
  emits('userTypeChanged', userType.value);
};
</script>
