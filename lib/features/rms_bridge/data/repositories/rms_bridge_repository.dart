import '../../../reservations/data/models/client.dart';
import '../../../reservations/data/models/hotel.dart';
import '../../../reservations/data/models/supplier.dart';
import '../models/rms_lookup_item.dart';
import '../models/rms_bridge_reservation_preview.dart';

typedef RmsBridgeLookups = ({
  List<Client> clients,
  List<Hotel> hotels,
  List<Supplier> suppliers,
});

typedef RmsBridgeAdditionalLookups = ({
  List<RmsLookupItem> nationalities,
  List<RmsLookupItem> extraServiceTypes,
  List<RmsLookupItem> termsAndConditions,
  List<RmsLookupItem> routes,
  List<RmsLookupItem> vehicleTypes,
  List<RmsLookupItem> tripTypes,
});

abstract class RmsBridgeRepository {
  Future<RmsBridgeReservationPreview> fetchReservationPreview({
    required String reservationId,
  });

  Future<RmsBridgeLookups> fetchCreateOrEditLookups({String rms = ''});

  Future<RmsBridgeAdditionalLookups> fetchAdditionalLookups();
}
