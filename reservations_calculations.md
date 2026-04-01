# توثيق الحسابات والمعادلات — Reservations

## 1. الهدف
هذا الملف يوضح كل الحسابات والمعادلات الحالية داخل Feature الحجوزات `lib/features/reservations`:
- كيف يتم الحساب
- أين يتم الحساب
- متى يتم حفظ الناتج
- متى يتم فقط إعادة تجميعه أو عرضه

## 2. القاعدة العامة
- كل الحسابات المالية تستخدم `Decimal` وليس `double`.
- حسابات الحفظ الأساسية تتم قبل الإرسال إلى الـRepository.
- بعض الشاشات تعيد تجميع totals عند العرض من البيانات المحفوظة، ولا تعيد توليد business totals من الصفر إلا في حالات عرض تفصيلية محددة.

---

## 3. Agent Reservation

### 3.1 مكان منطق الحساب الأساسي
الملف:
- `lib/features/reservations/provider/create_agent_reservation_provider.dart`

### 3.2 المعادلات

#### عدد الليالي
- المكان: `CreateAgentReservationState.nightsCount`
- المعادلة:

```text
Nights = departureDate - arrivalDate
```

- إذا كانت النتيجة أقل من أو تساوي صفر يتم إرجاع `0`.

#### تاريخ المغادرة
- المكان:
  - `onArrivalDateChanged`
  - `onNightsChanged`
- المعادلة:

```text
departureDate = arrivalDate + nights
```

#### تاريخ كل صف يومي داخل Room Rates
- المكان: `_syncRoomRatesWithDates`
- المعادلة:

```text
rowDate(i) = arrivalDate + i
```

#### عدد الركاب للغرفة المضافة
- المكان: `addRoomToSummary`
- المعادلة:

```text
PAX = roomsCount × paxPerRoom
```

- `paxPerRoom` مأخوذ من نوع الغرفة:
  - Single = 1
  - Double = 2
  - Twin = 2
  - Triple = 3
  - Family = 4
  - الافتراضي = 2

#### إجمالي RN
- المكان: `addRoomToSummary`
- المعادلة:

```text
Total RN = roomsCount × nightsCount
```

#### إجمالي البيع للخدمة الفندقية
- المكان: `_calculateTotals`
- لكل يوم:

```text
dailySale = (saleRoom × roomCount) + (saleMealPerPax × pax)
```

- الإجمالي:

```text
totalSale = Σ dailySale
```

#### إجمالي التكلفة للخدمة الفندقية
- المكان: `_calculateTotals`
- لكل يوم:

```text
dailyCost = (costRoom × roomCount) + (costMealPerPax × pax)
```

- الإجمالي:

```text
totalCost = Σ dailyCost
```

#### إجمالي الركاب على مستوى الخدمة
- المكان: `CreateAgentReservationState.totalPax`

```text
serviceTotalPax = Σ room.pax
```

#### إجمالي البيع على مستوى الخدمة
- المكان: `CreateAgentReservationState.totalSale`

```text
serviceTotalSale = Σ room.totalSale
```

#### إجمالي التكلفة على مستوى الخدمة
- المكان: `CreateAgentReservationState.totalCost`

```text
serviceTotalCost = Σ room.totalCost
```

### 3.3 مكان المعاينة داخل الشاشة
الملف:
- `lib/features/reservations/ui/screens/create_agent_reservation_screen.dart`

هذه الشاشة تعيد حساب القيم نفسها بغرض العرض المباشر فقط:
- `pax = roomsCount × paxPerRoom`
- `saleMealPrice = saleMealPerPax × pax`
- `salePrice = saleRoom + saleMealPrice`
- `costMealPrice = costMealPerPax × pax`
- `costPrice = costRoom + costMealPrice`
- ثم تجمع المجاميع النهائية اليومية في صف الـtotals السفلي.

هذا الحساب هو حساب عرض حي Live Preview وليس المصدر النهائي للحفظ.

### 3.4 أين يتم الحفظ
- المصدر قبل الحفظ: `create_agent_reservation_provider.dart`
- التحويل إلى Domain: `_toDomainDraft`
- الإرسال إلى الـRepository:
  - `addAgentService`
  - `updateAgentService`

### 3.5 ماذا يُحفظ
يتم حفظ القيم التالية داخل الخدمة:
- `roomsSummary[].totalSale`
- `roomsSummary[].totalCost`
- `roomsSummary[].totalRn`
- `totalPax`
- `totalSale`
- `totalCost`

---

## 4. General Service

### 4.1 مكان الحساب
الملف:
- `lib/features/reservations/ui/screens/create_general_service_screen.dart`

### 4.2 المعادلات

#### عدد الأيام بين بداية ونهاية الخدمة
- الأماكن:
  - عند تحميل بيانات التعديل
  - `_onDateOfServiceChanged`
  - `_onEndDateChanged`

```text
days = endDate - dateOfService
```

#### عند تعديل الأيام يدويًا
- المكان: `_onDaysChanged`

```text
endDate = dateOfService + days
```

#### إجمالي البيع
- المكان: `_save`
- المعادلة:

```text
totalSale = salePerItem × quantity
```

#### إجمالي التكلفة
- المكان: `_save`
- المعادلة:

```text
totalCost = costPerItem × quantity
```

### 4.3 حسابات العرض المباشر
- المكان: `_buildFinancialGrid`
- يتم إعادة نفس الحسابات لحظيًا داخل الواجهة:

```text
previewTotalSale = salePerItem × quantity
previewTotalCost = costPerItem × quantity
```

### 4.4 أين يتم الحفظ
- عند الضغط Save/Update يتم إنشاء `GeneralServiceDraft`
- ثم استدعاء:
  - `addGeneralService`
  - `updateGeneralService`

### 4.5 القيم المحفوظة
- `quantity`
- `salePerItem`
- `costPerItem`
- `totalSale`
- `totalCost`

---

## 5. Transportation Service

### 5.1 مكان الحساب
الملف:
- `lib/features/reservations/ui/screens/create_transportation_service_screen.dart`

### 5.2 المعادلات

#### إجمالي البيع للخدمة
- المكان: `_save`

لكل رحلة:

```text
tripSale = globalSalePerItem × quantity
```

الإجمالي:

```text
totalSale = Σ tripSale
```

#### إجمالي التكلفة للخدمة
- المكان: `_save`

لكل رحلة:

```text
tripCost = globalCostPerItem × quantity
```

الإجمالي:

```text
totalCost = Σ tripCost
```

### 5.3 حسابات جدول التسعير الظاهر
- المكان: `_buildPricingTable`

```text
itemsDecimal = itemsCount
salePrice = salePerItem × itemsCount
saleVat = 0
saleTotal = salePrice + saleVat

costPrice = costPerItem × itemsCount
costVat = 0
costTotal = costPrice + costVat
```

ملاحظة:
- الـVAT في التنفيذ الحالي ثابت بصفر.

### 5.4 أين يتم الحفظ
- يتم بناء `TransportationServiceDraft`
- ثم استدعاء:
  - `addTransportationService`
  - `updateTransportationService`

### 5.5 القيم المحفوظة
- `trips[].quantity`
- `trips[].pax`
- `trips[].salePerItem`
- `trips[].costPerItem`
- `totalSale`
- `totalCost`

---

## 6. Repository Read-Side Calculations

### 6.1 الملف
- `lib/features/reservations/data/repositories/reservations_repository_impl.dart`

### 6.2 لماذا توجد حسابات هنا؟
لأن بعض بيانات القراءة تحتاج fallback آمن:
- إذا كانت قيم `total_sale` و`total_cost` موجودة في الأعمدة، تستخدم مباشرة.
- إذا كانت هناك totals أدق أو متاحة داخل `payload`، يتم استخراجها واستخدامها.

### 6.3 المعادلات

#### إجمالي الخدمة النهائي عند القراءة
- المكان: `_mapServiceSummary`

```text
finalTotalSale = payload.totalSale ?? row.total_sale
finalTotalCost = payload.totalCost ?? row.total_cost
```

#### Agent totals من payload
- المكان: `_tryParseAgentTotals`

```text
payloadAgentSale = Σ roomsSummary.totalSale
payloadAgentCost = Σ roomsSummary.totalCost
```

#### Transportation totals من payload
- المكان: `_tryParseTransportationTotals`

```text
payloadTransportationSale = Σ (salePerItem × quantity)
payloadTransportationCost = Σ (costPerItem × quantity)
```

#### General Service fallback
- المكان: `_mapGeneralDraft`

إذا لم تكن `salePerItem` أو `costPerItem` موجودة في payload قديم:

```text
salePerItem = totalSale
costPerItem = totalCost
quantity = 1 إذا كانت quantity غير صالحة
```

---

## 7. Reservation Details Screen

### 7.1 مجاميع الصفحة
الملف:
- `lib/features/reservations/ui/utils/reservation_details_calculations.dart`

المعادلات:

```text
pageTotalSale = Σ service.totalSale
pageTotalCost = Σ service.totalCost
```

هذه القيم مجمعة من الخدمات المحفوظة، وليست حسابًا أوليًا جديدًا للخدمة.

### 7.2 داخل شاشة التفاصيل
الملف:
- `lib/features/reservations/ui/screens/reservation_details_screen.dart`

#### إجمالي بيع/تكلفة كل Trip

```text
tripTotalSale = salePerItem × quantity
tripTotalCost = costPerItem × quantity
```

#### عدد الليالي لخدمة Agent داخل التفاصيل

```text
agentNights = departureDate - arrivalDate
```

#### إجمالي RN داخل التفاصيل

```text
agentTotalRn = Σ room.totalRn
```

---

## 8. Reservation List Screen

### 8.1 الملف
- `lib/features/reservations/ui/screens/reservation_list_screen.dart`

### 8.2 المعادلات

#### إجمالي البيع في صف الحجز الرئيسي

```text
rowTotalSale = Σ service.totalSale
```

#### إجمالي مجموعة Agent

```text
agentGroupSale = Σ service.totalSale
agentGroupCost = Σ service.totalCost
```

#### إجمالي مجموعة Services

```text
servicesGroupSale = Σ service.totalSale
servicesGroupCost = Σ service.totalCost
```

#### Grand Total

```text
grandTotalSale = Σ service.totalSale
grandTotalCost = Σ service.totalCost
```

#### كمية خدمة المواصلات في القائمة

```text
transportationQty = Σ trip.quantity
```

---

## 9. أين يتم حساب الإجمالات فعليًا وأين يتم فقط عرضها؟

### يتم حسابها للحفظ هنا
- `create_agent_reservation_provider.dart`
- `create_general_service_screen.dart`
- `create_transportation_service_screen.dart`

هذه الأماكن هي المصدر الأساسي الذي ينتج totals قبل إرسالها للحفظ.

### يتم إعادة تجميعها أو عرضها هنا
- `reservation_details_calculations.dart`
- `reservation_details_screen.dart`
- `reservation_list_screen.dart`
- `reservations_repository_impl.dart`

هذه الأماكن لا تُنشئ business data جديدة للخدمة نفسها، لكنها:
- تجمع totals محفوظة
- أو تستنتج fallback totals من payload
- أو تعرض totals لكل item/row/trip

---

## 10. التسلسل الكامل للحساب والحفظ

### Agent Reservation
1. المستخدم يدخل التواريخ والأسعار وعدد الغرف.
2. الـProvider يحسب:
   - Nights
   - PAX
   - RN
   - totalSale
   - totalCost
3. يتم تكوين `AgentReservationDraft`.
4. الـRepository/RemoteDataSource يحفظ:
   - `total_sale`
   - `total_cost`
   - `payload`
5. عند القراءة، يتم تحميل totals من الأعمدة أو من payload fallback.

### General Service
1. المستخدم يدخل `salePerItem`, `costPerItem`, `quantity`.
2. الشاشة تحسب `totalSale` و`totalCost`.
3. يتم الحفظ داخل الخدمة.
4. لاحقًا تعرض القائمة/التفاصيل نفس totals المحفوظة أو المجمعات الناتجة عنها.

### Transportation Service
1. المستخدم يدخل السعر العام لكل مشوار ويحدد كميات الرحلات.
2. الشاشة تجمع:
   - `Σ (salePerItem × quantity)`
   - `Σ (costPerItem × quantity)`
3. يتم حفظ الإجماليات مع تفاصيل الرحلات.
4. عند القراءة، يمكن إعادة حساب fallback من الرحلات إذا احتاج الـRepository ذلك.

---

## 11. ملاحظة مهمة
تم أيضًا وضع تعليقات مباشرة داخل الكود تبدأ بـ:

```text
//CALCULATIONS
```

قبل أسطر الحساب الأساسية، حتى يصبح تتبع المعادلات أسهل أثناء التطوير والصيانة.
