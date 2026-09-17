<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Setting;
use Carbon\Carbon;

class SettingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
       
        $modules = [
            [
                'name' => 'pet_daycare_amount',
                'val' => 100,
                'type' =>'booking_config', 
            ],
            [
                'name' => 'pet_boarding_amount',
                'val' => 200,
                'type' =>'booking_config', 
            ],
            [
                'name' => 'is_one_signal_notification',
                'val' => 1,
                'type' =>'integaration', 
            ],

            [
                'name' => 'is_application_link',
                'val' => 1,
                'type' =>'integaration', 
            ],
            [
                'name' => 'customer_app_play_store',
                'val' => 'https://play.google.com/store/apps/details?id=com.pawlly.customer',
                'type' =>'is_application_link', 
            ],
            [
                'name' => 'customer_app_app_store',
                'val' => 'https://apps.apple.com/in/app/pawlly/id6458044939',
                'type' =>'is_application_link', 
            ],
            [
                'name' => 'employee_app_play_store',
                'val' => 'https://play.google.com/store/apps/details?id=com.pawlly.employee',
                'type' =>'is_application_link', 
            ],
            [
                'name' => 'employee_app_app_store',
                'val' => 'https://apps.apple.com/us/app/pawlly-for-employee/id6462849036',
                'type' =>'is_application_link', 
            ],
            [
                'name' => 'is_zoom',
                'val' => 1,
                'type' =>'integaration', 
            ],
            [
                'name' => 'account_id',
                'val' => '',
                'type' =>'is_zoom', 
            ],
            [
                'name' => 'client_id',
                'val' => '',
                'type' =>'is_zoom', 
            ],
            [
                'name' => 'client_secret',
                'val' => '',
                'type' =>'is_zoom', 
            ],

            [
                'name' => 'razor_payment_method',
                'val' => 1,
                'type' =>'razorpayPayment', 
            ],
            [
                'name' => 'razorpay_secretkey',
                'val' => '',
                'type' =>'razor_payment_method', 
            ],
            [
                'name' => 'razorpay_publickey',
                'val' => '',
                'type' =>'razor_payment_method', 
            ],
            [
                'name' => 'str_payment_method',
                'val' => 1,
                'type' =>'stripePayment', 
            ],
            [
                'name' => 'stripe_secretkey',
                'val' => '',
                'type' =>'str_payment_method', 
            ],
            [
                'name' => 'stripe_publickey',
                'val' => '',
                'type' =>'str_payment_method', 
            ],
            [
                'name' => 'paystack_payment_method',
                'val' => 1,
                'type' =>'paystackPayment', 
            ],
            [
                'name' => 'paystack_secretkey',
                'val' => '',
                'type' =>'paystack_payment_method', 
            ],
            [
                'name' => 'paystack_publickey',
                'val' => '',
                'type' =>'paystack_payment_method', 
            ],
            [
                'name' => 'paypal_payment_method',
                'val' => 1,
                'type' =>'paypalPayment', 
            ],
            [
                'name' => 'paypal_secretkey',
                'val' => '',
                'type' =>'paypal_payment_method', 
            ],
            [
                'name' => 'paypal_clientid',
                'val' => '',
                'type' =>'paypal_payment_method', 
            ],
            [
                'name' => 'flutterwave_payment_method',
                'val' => 1,
                'type' =>'flutterwavePayment', 
            ],
            [
                'name' => 'flutterwave_secretkey',
                'val' => '',
                'type' =>'flutterwave_payment_method', 
            ],
            [
                'name' => 'flutterwave_publickey',
                'val' => '',
                'type' =>'flutterwave_payment_method', 
            ],
            [
                'name' => 'is_event',
                'val' => 1,
                'type' =>'other_settings', 
            ],
            [
                'name' => 'is_blog',
                'val' => 1,
                'type' =>'other_settings', 
            ],
            [
                'name' => 'is_user_push_notification',
                'val' => 1,
                'type' =>'other_settings', 
            ],
            [
                'name' => 'is_provider_push_notification',
                'val' => 1,
                'type' =>'other_settings', 
            ],
            [
                'name' => 'default_time_zone',
                'val' => 'Asia/Kolkata',
                'type' =>'misc', 
            ],

            // [
            //     'name' => 'notification',
            //     'val' => 'firebase_notification',
            //     'type' =>'other_settings', 
            // ],
            // [
            //     'name' => 'firebase_key',
            //     'val' => 'AAAAtKuRt0I:APA91bE_PtkhVqJZXk0R0nIdeMk83KRgqxD9Jb94FwDbIPbR1HkuyZ8rcy6d9im7qXRXcq1N5Bm204YFTvINaFdxRl671rTizWYPWmZxcCQ1GNGjatMAxijlJ-w1oSFnZ-LGUMrLX77O',
            //     'type' =>'firebase_notification', 
            // ],

            [
                'name' => 'firebase_notification',
                'val' => '1',
                'type' =>'other_settings', 
            ],
            [
                'name' => 'firebase_project_id',
                'val' => 'pawlly-flutter',
                'type' =>'firebase_notification', 
            ],
            [
                'name' => 'enable_multi_vendor',
                'val' => '0',
                'type' =>'other_settings', 
            ],

            [
                'name' => 'enable_new_petstore_login',
                'val' => '1',
                'type' =>'other_settings', 
            ],

            [
                'name' => 'social_login',
                'val' => '1',
                'type' =>'other_settings', 
            ],
            [
                'name' => 'google_login',
                'val' => '1',
                'type' =>'other_settings', 
            ],
            [
                'name' => 'apple_login',
                'val' => '1',
                'type' =>'other_settings', 
            ],



        ];
        foreach ($modules as $key => $value) {
        
            $service = [
                'name' => $value['name'],
                'val' => $value['val'],
                'type' => $value['type']
            ];
            $service = Setting::create($service);
        }

    }
}
