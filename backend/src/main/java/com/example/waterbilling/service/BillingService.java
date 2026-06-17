package com.example.waterbilling.service;

import com.example.waterbilling.dto.BillDto;
import com.example.waterbilling.dto.MeterReadingRequest;
import com.example.waterbilling.dto.SyncRequest;
import com.example.waterbilling.entity.Bill;
import com.example.waterbilling.entity.CollectionStatus;
import com.example.waterbilling.entity.Customer;
import com.example.waterbilling.repository.BillRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class BillingService {
    private static final BigDecimal UNIT_PRICE = BigDecimal.valueOf(12000);
    private static final BigDecimal VAT_RATE = BigDecimal.valueOf(0.10);

    private final BillRepository billRepository;
    private final CustomerService customerService;

    public BillingService(BillRepository billRepository, CustomerService customerService) {
        this.billRepository = billRepository;
        this.customerService = customerService;
    }

    @Transactional(readOnly = true)
    public List<BillDto> getAll() {
        return billRepository.findAllByOrderByDateDesc().stream().map(BillDto::from).toList();
    }

    @Transactional(readOnly = true)
    public List<BillDto> getByCustomer(Long customerId) {
        return billRepository.findByCustomerIdOrderByDateDesc(customerId).stream().map(BillDto::from).toList();
    }

    @Transactional(readOnly = true)
    public List<BillDto> getUnsynced() {
        return billRepository.findBySyncedFalseOrderByDateDesc().stream().map(BillDto::from).toList();
    }

    @Transactional
    public BillDto createFromMeterReading(Long customerId, MeterReadingRequest request) {
        Customer customer = customerService.findEntity(customerId);
        if (request.newReading() < customer.getCurrentReading()) {
            throw new IllegalArgumentException("Chỉ số mới không được nhỏ hơn chỉ số cũ");
        }

        int consumption = request.newReading() - customer.getCurrentReading();
        BigDecimal amount = UNIT_PRICE.multiply(BigDecimal.valueOf(consumption)).setScale(2, RoundingMode.HALF_UP);
        BigDecimal vat = amount.multiply(VAT_RATE).setScale(2, RoundingMode.HALF_UP);

        Bill bill = new Bill();
        bill.setCustomer(customer);
        bill.setBillCode(nextBillCode(customer));
        bill.setDate(LocalDateTime.now());
        bill.setOldReading(customer.getCurrentReading());
        bill.setNewReading(request.newReading());
        bill.setConsumption(BigDecimal.valueOf(consumption).setScale(2, RoundingMode.HALF_UP));
        bill.setUnitPrice(UNIT_PRICE.setScale(2, RoundingMode.HALF_UP));
        bill.setAmount(amount);
        bill.setVat(vat);
        bill.setTotalAmount(amount.add(vat).setScale(2, RoundingMode.HALF_UP));
        bill.setImagePath(request.imagePath());
        bill.setSynced(false);

        customer.setCurrentReading(request.newReading());
        customer.setStatus(CollectionStatus.COMPLETED);

        return BillDto.from(billRepository.save(bill));
    }

    @Transactional
    public List<BillDto> sync(SyncRequest request) {
        return request.bills().stream().map(this::upsertSyncedBill).toList();
    }

    @Transactional
    public BillDto markSynced(Long id) {
        Bill bill = billRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy hóa đơn id=" + id));
        bill.setSynced(true);
        return BillDto.from(bill);
    }

    private BillDto upsertSyncedBill(BillDto dto) {
        Bill bill = billRepository.findByBillCode(dto.billCode()).orElseGet(Bill::new);
        Customer customer = customerService.findEntity(dto.customerId());

        bill.setCustomer(customer);
        bill.setBillCode(dto.billCode());
        bill.setDate(dto.date() == null ? LocalDateTime.now() : dto.date());
        bill.setOldReading(dto.oldReading());
        bill.setNewReading(dto.newReading());
        bill.setConsumption(dto.consumption());
        bill.setUnitPrice(dto.unitPrice());
        bill.setAmount(dto.amount());
        bill.setVat(dto.vat());
        bill.setTotalAmount(dto.totalAmount());
        bill.setImagePath(dto.imagePath());
        bill.setSynced(true);

        if (dto.newReading() > customer.getCurrentReading()) {
            customer.setCurrentReading(dto.newReading());
            customer.setStatus(CollectionStatus.COMPLETED);
        }

        return BillDto.from(billRepository.save(bill));
    }

    private String nextBillCode(Customer customer) {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        return "HD" + timestamp + customer.getCode();
    }
}
