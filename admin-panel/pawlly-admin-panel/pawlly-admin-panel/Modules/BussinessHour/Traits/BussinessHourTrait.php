<?php

namespace Modules\BussinessHour\Traits;


use Carbon\Carbon;
use Modules\BussinessHour\Models\BussinessHour;
use Modules\Holiday\Models\Holiday;

trait BussinessHourTrait
{
    /**
     * Get working days with holidays and breaks
     *
     * @param int $branchId
     * @return \Illuminate\Support\Collection
     */
    public function getWorkingDays($branchId)
    {
        $holidays = Holiday::where('branch_id', $branchId)->get();
        $businessHours = BussinessHour::where('branch_id', $branchId)->get();

        return $businessHours->map(function ($hour) use ($holidays) {
            // Convert day to ISO format (Mon=1 ... Sun=7)
            if (is_numeric($hour->day)) {
                $dayIso = (int) $hour->day;
                if ($dayIso === 0) {
                    $dayIso = 7;
                }
            } else {
                $dayIso = Carbon::parse($hour->day)->dayOfWeekIso;
            }

            // Get actual date for that weekday in the current week
            $dayDate = Carbon::now()->startOfWeek(Carbon::MONDAY)
                ->addDays($dayIso - 1)
                ->format('Y-m-d');

            // Check if this day is a festival holiday
            $isFestivalHoliday = $holidays->contains(
                fn($holiday) => $holiday->date === $dayDate
            ) ? 1 : 0;

            return [
                'day'                 => ucfirst(Carbon::parse($dayDate)->format('l')), // e.g. "Monday"
                'start_time'          => $hour->start_time,
                'end_time'            => $hour->end_time,
                'date'                => $dayDate,
                'is_holiday'          => (int) $hour->is_holiday,
                'is_festival_holiday' => $isFestivalHoliday,
                'breaks'              => $hour->breaks,
            ];
        });
    }
}
