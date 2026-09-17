<style>
    body {
        font-family: DejaVu Sans, sans-serif;
        font-size: 12px;
    }
    .invoice-container {
        width: 100%;
        padding: 10px;
    }
    .header-table, .info-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 15px;
    }
    .header-table td, .info-table td {
        vertical-align: top;
        padding: 5px;
    }
    .text-right { text-align: right; }
    .order-table {
        width: 100%;
        border-collapse: collapse;
    }
    .order-table th, .order-table td {
        border: 1px solid #ddd;
        padding: 6px;
    }
    .order-table th {
        background: #f2f2f2;
    }
    .total-row td {
        text-align: right;
        font-weight: bold;
    }
</style>

<div class="invoice-container">

    <!-- Header -->
    <table class="header-table">
        <tr>
            <td>
                <h3>Customer Info</h3>
                <p>Name: <strong>{{ optional(optional($orderItem->order)->user)->full_name ?? 'N/A' }}</strong></p>
                <p>Email: <strong>{{ optional(optional($orderItem->order)->user)->email ?? 'N/A' }}</strong></p>
                <p>Phone: <strong>{{ optional(optional($orderItem->order)->user)->mobile ?? 'N/A' }}</strong></p>
            </td>
            <td class="text-right">
                <h3>Invoice: {{ setting('inv_prefix') }}{{ optional(optional($orderItem->order)->orderGroup)->order_code }}</h3>
                <p>Order Date: {{ date('d M, Y', strtotime($orderItem->created_at)) }}</p>
                @if ($orderItem->order->location_id)
                    <p><i class="las la-map-marker"></i> {{ optional(optional($orderItem->order)->location)->name }}</p>
                @endif
                @php
                    $expected_delivery_date = \Carbon\Carbon::parse($orderItem->expected_delivery_date)->format('d-m-Y');
                @endphp
                <p><strong>Expected Delivery Date:</strong> {{ $expected_delivery_date }}</p>
            </td>
        </tr>
    </table>

    <!-- Payment & Shipping -->
    <table class="info-table">
        <tr>
            <td>
                <p><strong>Payment Method:</strong> {{ ucwords(str_replace('_', ' ', optional(optional($orderItem->order)->orderGroup)->payment_method)) }}</p>
                <p><strong>Logistic:</strong> {{ $orderItem->order->logistic_name ?? 'N/A' }}</p>
            </td>
            <td>
                <p><strong>Shipping Address:</strong><br>
                    @php $shippingAddress = optional(optional($orderItem->order)->orderGroup)->shippingAddress; @endphp
                    @if($shippingAddress)
                        {{ optional($shippingAddress)->address_line_1 }},
                        {{ optional($shippingAddress->city_data)->name }},
                        {{ optional($shippingAddress->state_data)->name }},
                        {{ optional($shippingAddress->country_data)->name }}
                    @endif
                </p>

                @if(!$orderItem->order->orderGroup->is_pos_order)
                    <p><strong>Billing Address:</strong><br>
                        @php $billingAddress = optional(optional($orderItem->order)->orderGroup)->billingAddress; @endphp
                        @if($billingAddress)
                            {{ optional($billingAddress)->address_line_1 }},
                            {{ optional($billingAddress->city_data)->name }},
                            {{ optional($billingAddress->state_data)->name }},
                            {{ optional($billingAddress->country_data)->name }}
                        @endif
                    </p>
                @endif
            </td>
        </tr>
    </table>

    <!-- Items -->
    <table class="order-table">
        <thead>
            <tr>
                <th>#</th>
                <th>Title</th>
                <th>Unit Price</th>
                <th>Qty</th>
                <th>Total Price</th>
            </tr>
        </thead>
        <tbody>
            @php
                $product = optional($orderItem->product_variation)->product;
                $totalprice = $orderItem->total_price;
                $totalTaxAmount = $orderItem->total_tax;
                $totalShippingCost = $orderItem->total_shipping_cost;
                $totalOrderPrice = $totalprice + $totalTaxAmount + $totalShippingCost;
            @endphp
            <tr>
                <td>1</td>
                <td>
                    {{ optional($product)->name ?? '--' }}
                    @if(!empty($orderItem->product_variation))
                        <div>
                            @foreach(generateVariationOptions($orderItem->product_variation->combinations) as $variation)
                                {{ $variation['name'] }}:
                                @foreach($variation['values'] as $value) {{ $value['name'] }} @endforeach
                                @if(!$loop->last), @endif
                            @endforeach
                        </div>
                    @endif
                </td>
                <td>{{ \Currency::format($orderItem->unit_price) }}</td>
                <td>{{ $orderItem->qty }}</td>
                <td class="text-right">
                    @if ($orderItem->refundRequest && $orderItem->refundRequest->refund_status == 'refunded')
                        <span class="badge bg-soft-info text-capitalize">
                            {{ $orderItem->refundRequest->refund_status }}
                        </span>
                    @endif
                    {{ \Currency::format($orderItem->total_price) }}
                </td>
            </tr>
        </tbody>
        <tfoot>
            <tr class="total-row">
                <td colspan="4">Tax:</td>
                <td>{{ \Currency::format($orderItem->total_tax) }}</td>
            </tr>
            <tr class="total-row">
                <td colspan="4">Shipping Cost:</td>
                <td>{{ \Currency::format($orderItem->total_shipping_cost) }}</td>
            </tr>
            <tr class="total-row">
                <td colspan="4">Total:</td>
                <td>{{ \Currency::format($totalOrderPrice) }}</td>
            </tr>
            @if(optional(optional($orderItem->order)->orderGroup)->total_coupon_discount_amount > 0)
                <tr class="total-row">
                    <td colspan="4">Coupon Discount:</td>
                    <td>{{ \Currency::format(optional(optional($orderItem->order)->orderGroup)->total_coupon_discount_amount) }}</td>
                </tr>
            @endif
        </tfoot>
    </table>

    <!-- Other Items -->
    @if($otherItems->isNotEmpty())
        <h4>Other Items</h4>
        @foreach($otherItems as $key => $item)
            @php
                $product = optional($item->product_variation)->product;
                $totalprice = $item->total_price;
                $totalTaxAmount = $item->total_tax;
                $totalShippingCost = $item->total_shipping_cost;
                $totalOrderPrice = $totalprice + $totalTaxAmount + $totalShippingCost;
            @endphp
            <table class="order-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Title</th>
                        <th>Unit Price</th>
                        <th>Qty</th>
                        <th>Total Price</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>{{ $key + 1 }}</td>
                        <td>
                            {{ optional($product)->name ?? '--' }}
                            @if(!empty($item->product_variation))
                                <div>
                                    @foreach(generateVariationOptions($item->product_variation->combinations) as $variation)
                                        {{ $variation['name'] }}:
                                        @foreach($variation['values'] as $value) {{ $value['name'] }} @endforeach
                                        @if(!$loop->last), @endif
                                    @endforeach
                                </div>
                            @endif
                        </td>
                        <td>{{ \Currency::format($item->unit_price) }}</td>
                        <td>{{ $item->qty }}</td>
                        <td class="text-right">
                            @if ($item->refundRequest && $item->refundRequest->refund_status == 'refunded')
                                <span class="badge bg-soft-info text-capitalize">
                                    {{ $item->refundRequest->refund_status }}
                                </span>
                            @endif
                            {{ \Currency::format($item->total_price) }}
                        </td>
                    </tr>
                </tbody>
                <tfoot>
                    <tr class="total-row">
                        <td colspan="4">Tax:</td>
                        <td>{{ \Currency::format($item->total_tax) }}</td>
                    </tr>
                    <tr class="total-row">
                        <td colspan="4">Shipping Cost:</td>
                        <td>{{ \Currency::format($item->total_shipping_cost) }}</td>
                    </tr>
                    <tr class="total-row">
                        <td colspan="4">Total:</td>
                        <td>{{ \Currency::format($totalOrderPrice) }}</td>
                    </tr>
                    <tr class="total-row">
                        <td colspan="4">Grand Total:</td>
                        <td>{{ \Currency::format(optional(optional($orderItem->order)->orderGroup)->grand_total_amount) }}</td>
                    </tr>
                </tfoot>
            </table>
        @endforeach
    @endif

    <!-- Footer -->
    <p style="margin-top:20px;">{{ setting('spacial_note') }}</p>
</div>
