import '../interface/camera.dart';
import '../interface/camera_factory.dart';
import 'actions/action_factory.dart';
import 'adapter/eos_ptp_event_processor.dart';
import 'adapter/get_eos_events_delegate.dart';
import 'adapter/ptp_request_factory.dart';
import 'cache/ptp_property_cache.dart';
import 'communication/ptp_ip_channel.dart';
import 'communication/ptp_ip_client.dart';
import 'communication/ptp_transaction_queue.dart';
import 'eos_ptp_ip_camera.dart';
import 'eos_ptp_ip_camera_descriptor.dart';
import 'extensions/stream_extensions.dart';
import 'logging/eos_ptp_ip_logger.dart';
import 'responses/ptp_init_command_response.dart';
import 'responses/ptp_init_event_response.dart';

class EosPtpIpCameraFactory extends CameraFactory<EosPtpIpCameraDescriptor> {
  static const ptpIpPort = 15740;

  final ActionFactory _actionFactory;
  final EosPtpIpLogger logger = EosPtpIpLogger();

  EosPtpIpCameraFactory([
    this._actionFactory = const ActionFactory(),
  ]);

  @override
  Future<Camera> connect(EosPtpIpCameraDescriptor descriptor) async {
    logger.info('Attempting to open command channel');
    final commandChannel =
        await PtpIpChannel.connect(descriptor.address, ptpIpPort);

    logger.info('Sending initCommand request');
    await commandChannel.write(PtpRequestFactory().createInitCommandRequest(
        name: descriptor.clientName, guid: descriptor.guid));

    final initCommandResponse = await commandChannel.onResponse
        .firstWhereType<PtpInitCommandResponse>()
        .timeout(const Duration(seconds: 10));

    logger.info(
        'Received initCommand response with connectionNumber: ${initCommandResponse.connectionNumber}');

    logger.info('Attempting to open event channel');
    final eventChannel =
        await PtpIpChannel.connect(descriptor.address, ptpIpPort);

    logger.info("Sending initEvent request");
    await eventChannel.write(PtpRequestFactory().createInitEventRequest(
        connectionNumber: initCommandResponse.connectionNumber));

    await eventChannel.onResponse
        .firstWhereType<PtpInitEventResponse>()
        .timeout(const Duration(seconds: 10));

    logger.info('Received initEvent response');

    final client = PtpIpClient(commandChannel, eventChannel);
    final transactionQueue = PtpTransactionQueue(client);

    final initSession = _actionFactory.createInitSessionAction();
    await initSession.run(transactionQueue);

    logger.info('Requesting initial event data');
    final getEventData = _actionFactory.createGetEventsAction();
    final updateEvents = await getEventData.run(transactionQueue);

    logger.info('Init property cache with event data');
    final propertyCache = PtpPropertyCache();
    propertyCache.update(updateEvents);

    final eventProcessor = EosPtpEventProcessor(
      GetEosEventsDelegate(
        transactionQueue,
        _actionFactory,
      ),
      propertyCache,
    );

    logger.info('Initialization finished');
    return EosPtpIpCamera(
      transactionQueue,
      _actionFactory,
      eventProcessor,
    );
  }
}
